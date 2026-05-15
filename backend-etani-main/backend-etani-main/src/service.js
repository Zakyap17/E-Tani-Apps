import { generateMultiDayInsight } from './classifier.js';
import { generateDailyActivities } from './aiService.js';

// WMO Weather Code to Indonesian label (More Precise)
function wmoToLabel(code, probability = 0) {
  // Jika peluang hujan sangat rendah (< 20%), abaikan kode hujan/badai
  if (probability < 20 && code > 3) {
    if (code <= 48) return 'Berawan'; // Kabut jadi berawan
    if (code <= 99) return 'Berawan'; // Hujan/Badai tapi peluang kecil jadi berawan
  }

  if (code === 0) return 'Cerah';
  if (code <= 3) return 'Berawan';
  if (code <= 48) return 'Kabut';
  if (code <= 55) return 'Gerimis';
  if (code <= 65) return 'Hujan';
  if (code <= 77) return 'Salju/Hujan Es';
  if (code <= 82) return 'Hujan Lebat';
  if (code <= 99) return 'Badai';
  return 'Cerah';
}

// Geocode city name to lat/lon using Open-Meteo Geocoding (free, no key)
async function geocodeCity(cityName) {
  const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cityName)}&count=1&language=id&format=json`;
  const response = await fetch(url);
  const data = await response.json();
  if (!data.results || data.results.length === 0) {
    throw new Error(`Kota tidak ditemukan: ${cityName}`);
  }
  return {
    lat: data.results[0].latitude,
    lon: data.results[0].longitude,
    name: data.results[0].name,
  };
}

// Get city name from lat/lon using Open-Meteo Geocoding
async function reverseGeocode(lat, lon) {
  try {
    const url = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json&accept-language=id`;
    const response = await fetch(url, { headers: { 'User-Agent': 'e-Tani-App' } });
    const data = await response.json();
    const addr = data.address;
    // Prioritaskan nama yang paling detail (Desa -> Kecamatan -> Kota)
    return addr.village || addr.suburb || addr.city_district || addr.town || addr.city || 'Lokasi Terdeteksi';
  } catch (e) {
    return 'Lokasi Terdeteksi';
  }
}

export async function getTodayData(city, lat, lon, ip) {
  let locationName = city || 'Bandung';
  let latitude = lat;
  let longitude = lon;

  try {
    // 1. Jika ada GPS, gunakan GPS
    if (latitude && longitude) {
      locationName = await reverseGeocode(latitude, longitude);
    } 
    // 2. Jika GPS tidak ada, coba deteksi via IP (Baru!)
    else if (!city && ip) {
      try {
        const ipGeoUrl = `http://ip-api.com/json/${ip}?fields=status,city,lat,lon`;
        const ipRes = await fetch(ipGeoUrl);
        const ipData = await ipRes.json();
        if (ipData.status === 'success') {
          latitude = ipData.lat;
          longitude = ipData.lon;
          locationName = ipData.city;
        }
      } catch (e) {
        console.error("IP Geolocation error: " + e.message);
      }
    }

    // 3. Jika masih belum ada koordinat, gunakan geocode nama kota (default Bandung)
    if (!latitude || !longitude) {
      const geo = await geocodeCity(locationName);
      latitude = geo.lat;
      longitude = geo.lon;
      locationName = geo.name;
    }

    console.log(`[Weather Request] Loc: ${locationName}, Lat: ${latitude}, Lon: ${longitude}, IP: ${ip}`);


    // Ambil cuaca dari Open-Meteo (gratis, tanpa API key)
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,apparent_temperature,weathercode,relative_humidity_2m,precipitation_probability&hourly=temperature_2m,apparent_temperature,weathercode,precipitation_probability&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&forecast_days=3`;

    const response = await fetch(url);
    if (!response.ok) throw new Error(`Open-Meteo error: ${response.status}`);
    const data = await response.json();

    const current = data.current;
    const daily = data.daily;
    const hourly = data.hourly;

    const dayLabels = ['Hari Ini', 'Besok', 'Lusa'];
    const forecastArray = daily.time.slice(0, 3).map((_, i) => ({
      day: dayLabels[i],
      weather: wmoToLabel(daily.weathercode[i], daily.precipitation_probability_max[i]),
      temperature: Math.round((daily.temperature_2m_max[i] + daily.temperature_2m_min[i]) / 2),
      precipitation: daily.precipitation_probability_max[i],
    }));

    // Generate 48 jam forecast (Hari ini & Besok) agar bisa mendeteksi hujan besok
    const hourlyForecast = [];
    for (let i = 0; i < 48; i++) {
      if (!hourly.time[i]) break;
      const fullTime = hourly.time[i]; // 2026-05-14T18:00
      const shortTime = fullTime.split('T')[1]; // 18:00
      
      hourlyForecast.push({
        fullTime: fullTime,
        time: shortTime, // Ini yang akan dipakai di UI (Hanya jam)
        // Samakan logika: Gunakan apparent_temperature jika ada
        temp: Math.round(hourly.apparent_temperature ? hourly.apparent_temperature[i] : hourly.temperature_2m[i]),
        weather: wmoToLabel(hourly.weathercode[i], hourly.precipitation_probability[i]),
      });
    }

    const multiDayInsight = generateMultiDayInsight(forecastArray);

    // LOGIKA BARU: Deteksi Hujan yang lebih detail (Hari ini vs Besok)
    let weatherAlert = null;
    
    // Gunakan jam lokal dari data cuaca (Open-Meteo menyediakan waktu lokal di 'current.time')
    const localTimeStr = data.current.time; // Format: 2026-05-14T19:00
    const localHour = parseInt(localTimeStr.split('T')[1].split(':')[0]);
    
    // 1. Cari hujan di sisa hari ini (menggunakan jam lokal lokasi tersebut)
    const rainToday = hourlyForecast.slice(localHour + 1, 24).find(h => h.weather.includes('Hujan') || h.weather.includes('Badai'));
    
    // 2. Cari hujan besok (jam 24 sampai 48)
    const rainTomorrow = hourlyForecast.slice(24, 48).find(h => h.weather.includes('Hujan') || h.weather.includes('Badai'));

    if (rainToday) {
      const timeLabel = parseInt(rainToday.time.split(':')[0]) >= 18 ? "malam ini" : "hari ini";
      weatherAlert = `⚠️ WASPADA: Diprediksi akan ${rainToday.weather.toLowerCase()} ${timeLabel} sekitar pukul ${rainToday.time}.`;
    } else if (rainTomorrow) {
      weatherAlert = `ℹ️ INFO: Besok diprediksi akan ${rainTomorrow.weather.toLowerCase()} sekitar pukul ${rainTomorrow.time}. Persiapkan lahan Anda lebih awal.`;
    }

    const systemNotice = "🚀 TANI-AI TELAH HADIR: Update APK sekarang untuk fitur Konsultasi AI & Analisis Cuaca Real-time!";

    // GENERATE DYNAMIC ACTIVITIES VIA AI
    const weatherText = `Lokasi: ${locationName}, Cuaca: ${current.weather}, Suhu: ${current.temperature_2m}°C, Alert: ${weatherAlert || "Tidak ada"}`;
    const activities = await generateDailyActivities(weatherText, locationName);

    return {
      location: locationName,
      alert: weatherAlert, 
      system_notice: systemNotice, 
      activities: activities, // MASUKKAN KE RESPONSE
      insight: multiDayInsight.insight,
      action_plan: multiDayInsight.action_plan,
      current: {
        // Kembali ke Suhu Udara Asli agar sinkron dengan platform lain
        temperature: Math.round(current.temperature_2m),
        weather: wmoToLabel(current.weathercode, current.precipitation_probability),
        humidity: current.relative_humidity_2m,
        precipitation_probability: current.precipitation_probability,
        apparent_temperature: Math.round(current.apparent_temperature), // Simpan saja
      },
      recommendation: forecastArray[0].weather,
      forecast: forecastArray,
      hourly: hourlyForecast,
    };
  } catch (error) {
    console.error('Error fetching weather data:', error.message);
    throw new Error('Failed to retrieve weather data');
  }
}
