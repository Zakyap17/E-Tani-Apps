/**
 * scheduleService.js
 * Logika cerdas penghasil kegiatan harian per blok lahan.
 * Menggabungkan data umur tanaman (HST) dengan kondisi cuaca real-time.
 */

/**
 * Menghitung Hari Setelah Tanam (HST) dari tanggal tanam.
 * @param {string} plantingDate - Format 'YYYY-MM-DD'
 * @returns {number} HST (hari)
 */
export function calculateHST(plantingDate) {
  const planted = new Date(plantingDate);
  const today = new Date();
  planted.setHours(0, 0, 0, 0);
  today.setHours(0, 0, 0, 0);
  const diffMs = today - planted;
  return Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
}

/**
 * Menentukan fase pertumbuhan tanaman berdasarkan HST.
 * @param {number} hst
 * @returns {{ label: string, description: string }}
 */
export function getGrowthPhase(hst) {
  if (hst <= 14) {
    return { label: 'Perkecambahan', description: 'Fase kritis. Jaga kelembaban tanah selalu optimal.' };
  } else if (hst <= 35) {
    return { label: 'Vegetatif Awal', description: 'Pertumbuhan daun & batang. Fokus pupuk tinggi Nitrogen (N).' };
  } else if (hst <= 60) {
    return { label: 'Vegetatif Akhir', description: 'Tanaman siap berbunga. Kurangi N, tambah Fosfat (P).' };
  } else if (hst <= 90) {
    return { label: 'Generatif / Berbunga', description: 'Fase bunga & buah muda. Fokus Kalium (K) dan Fosfat (P).' };
  } else {
    return { label: 'Panen / Akhir Musim', description: 'Segera persiapkan panen atau evaluasi lahan.' };
  }
}

/**
 * Menghasilkan daftar tugas harian untuk satu blok.
 * @param {Object} block - Data blok dari DB { id, name, crop_type, planting_date }
 * @param {Object|null} weatherData - Data cuaca dari getTodayData() backend
 * @returns {Array} tasks
 */
export function generateTasksForBlock(block, weatherData) {
  const hst = calculateHST(block.planting_date);
  const phase = getGrowthPhase(hst);
  const tasks = [];

  // Ambil data cuaca jika tersedia
  const weather = weatherData?.current?.weather ?? 'Cerah';
  const temp = weatherData?.current?.temperature ?? 28;
  const humidity = weatherData?.current?.humidity ?? 70;
  const rainToday = weatherData?.alert?.includes('WASPADA') ?? false;
  const rainTodayTime = weatherData?.alert
    ? (weatherData.alert.match(/pukul (\d{2}:\d{2})/) ?? [])[1] ?? null
    : null;

  // 1. TUGAS PENYIRAMAN
  if (rainToday) {
    tasks.push({
      type: 'watering',
      title: 'Siram Tanaman',
      status: 'skip',
      time: 'Dilewati',
      reason: `Hujan diprediksi pukul ${rainTodayTime ?? '??:??'}. Kebutuhan air sudah tercukupi.`,
      iconType: 'water',
    });
  } else if (temp > 32) {
    tasks.push({
      type: 'watering',
      title: 'Siram Tanaman',
      status: 'action',
      time: '06:30 & 16:00',
      reason: `Suhu tinggi (${temp}°C). Tanaman butuh penyiraman ekstra 2x sehari.`,
      iconType: 'water',
    });
  } else {
    tasks.push({
      type: 'watering',
      title: 'Siram Tanaman',
      status: 'action',
      time: '07:00 & 16:30',
      reason: 'Penyiraman rutin untuk menjaga kelembaban akar.',
      iconType: 'water',
    });
  }

  // 2. TUGAS PEMUPUKAN (berdasarkan fase HST)
  let fertilizerTask = null;
  if (hst >= 7 && hst <= 35) {
    // Vegetatif: NPK (fokus Nitrogen)
    fertilizerTask = {
      type: 'fertilizer',
      title: 'Pupuk Fase Vegetatif',
      status: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16 ? 'skip' : 'action',
      time: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16 ? 'Tunda' : '08:00',
      reason: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16
        ? 'Tunda — risiko hanyut terbawa air hujan. Lakukan setelah cuaca stabil.'
        : `HST ${hst}. Gunakan pupuk NPK tinggi Nitrogen untuk mempercepat pertumbuhan vegetatif.`,
      iconType: 'leaf',
    };
  } else if (hst > 35 && hst <= 90) {
    // Generatif: KCl / TSP (fokus Kalium & Fosfat)
    fertilizerTask = {
      type: 'fertilizer',
      title: 'Pupuk Fase Generatif',
      status: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16 ? 'skip' : 'action',
      time: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16 ? 'Tunda' : '08:00',
      reason: rainToday && rainTodayTime && parseInt(rainTodayTime) < 16
        ? 'Tunda — risiko hanyut terbawa air hujan. Lakukan setelah cuaca stabil.'
        : `HST ${hst}. Gunakan pupuk KCl/TSP untuk memperkuat bunga dan buah.`,
      iconType: 'leaf',
    };
  }
  if (fertilizerTask) tasks.push(fertilizerTask);

  // 3. MONITORING HAMA & PENYAKIT
  if (humidity > 75 || weather.includes('Hujan') || weather.includes('Gerimis')) {
    tasks.push({
      type: 'monitoring',
      title: 'Cek Gejala Jamur',
      status: 'action',
      time: 'Pagi (Wajib)',
      reason: `Kelembaban ${humidity}% — kondisi ideal untuk tumbuhnya jamur. Periksa bagian bawah daun.`,
      iconType: 'bug',
    });
  } else {
    tasks.push({
      type: 'monitoring',
      title: 'Monitoring Hama',
      status: 'action',
      time: 'Siang Hari',
      reason: 'Cuaca kering. Waspadai kutu daun dan ulat penggerek di pucuk tanaman.',
      iconType: 'bug',
    });
  }

  // 4. DRAINASE (jika hujan lebat diprediksi)
  if (rainToday && (weather.includes('Lebat') || weather.includes('Badai'))) {
    tasks.push({
      type: 'drainage',
      title: 'Periksa Saluran Air',
      status: 'action',
      time: 'Pasca Hujan',
      reason: 'Hujan lebat diprediksi. Pastikan drainase lancar agar lahan tidak tergenang.',
      iconType: 'water',
    });
  }

  // 5. EVALUASI AKHIR HARI (selalu ada)
  tasks.push({
    type: 'evaluation',
    title: 'Evaluasi Tanaman',
    status: 'action',
    time: '17:00',
    reason: `Catat perkembangan ${block.crop_type} (HST ${hst}). Siapkan rencana kerja esok hari.`,
    iconType: 'leaf',
  });

  return {
    block_id: block.id,
    block_name: block.name,
    crop_type: block.crop_type,
    hst,
    phase: phase.label,
    phase_description: phase.description,
    tasks,
  };
}
