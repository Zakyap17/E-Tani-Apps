import { generateMultiDayInsight } from './classifier.js';

// WMO Weather Code to Indonesian label
function wmoToLabel(code) {
  if (code === 0) return 'Cerah';
  if (code <= 3) return 'Berawan';
  if (code <= 67) return 'Hujan';
  if (code <= 77) return 'Hujan Es';
  if (code <= 82) return 'Hujan Lebat';
  return 'Badai';
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

export async function getTodayData(city, lat, lon) {
  let locationName = city || 'Bandung';
  let latitude = lat;
  let longitude = lon;

  try {
    // Jika lat/lon langsung tersedia (dari GPS frontend), gunakan langsung
    if (!latitude || !longitude) {
      const geo = await geocodeCity(locationName);
      latitude = geo.lat;
      longitude = geo.lon;
      locationName = geo.name;
    }

    // Ambil cuaca dari Open-Meteo (gratis, tanpa API key)
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,weathercode,relative_humidity_2m,precipitation_probability&hourly=temperature_2m,weathercode&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&forecast_days=3`;

    const response = await fetch(url);
    if (!response.ok) throw new Error(`Open-Meteo error: ${response.status}`);
    const data = await response.json();

    const current = data.current;
    const daily = data.daily;
    const hourly = data.hourly;

    const dayLabels = ['Hari Ini', 'Besok', 'Lusa'];
    const forecastArray = daily.time.slice(0, 3).map((_, i) => ({
      day: dayLabels[i],
      weather: wmoToLabel(daily.weathercode[i]),
      temperature: Math.round((daily.temperature_2m_max[i] + daily.temperature_2m_min[i]) / 2),
      precipitation: daily.precipitation_probability_max[i],
    }));

    // Generate 24 jam forecast
    const currentHour = new Date().getHours();
    const hourlyForecast = [];
    for (let i = currentHour; i < currentHour + 24; i++) {
      hourlyForecast.push({
        time: hourly.time[i].split('T')[1],
        temp: Math.round(hourly.temperature_2m[i]),
        weather: wmoToLabel(hourly.weathercode[i]),
      });
    }

    const multiDayInsight = generateMultiDayInsight(forecastArray);

    return {
      location: locationName,
      insight: multiDayInsight.insight,
      action_plan: multiDayInsight.action_plan,
      current: {
        temperature: Math.round(current.temperature_2m),
        weather: wmoToLabel(current.weathercode),
        humidity: current.relative_humidity_2m,
        precipitation_probability: current.precipitation_probability,
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
