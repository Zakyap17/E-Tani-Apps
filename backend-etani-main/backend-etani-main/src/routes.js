import { Router } from 'express';
import multer from 'multer';
import { getTodayData } from './service.js';
import { query } from './db.js';
import { askTaniAI } from './aiService.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

router.get('/', (req, res) => {
  res.type('text/plain').send('e-Tani API is running');
});

router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

router.get('/today', async (req, res) => {
  try {
    const city = req.query.city;
    const lat = req.query.lat ? parseFloat(req.query.lat) : null;
    const lon = req.query.lon ? parseFloat(req.query.lon) : null;
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    const data = await getTodayData(city, lat, lon, ip);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/report', async (req, res) => {
  const { name, email, category, description } = req.body;
  if (!name || !email || !description) {
    return res.status(400).json({ error: 'Nama, email, dan deskripsi harus diisi' });
  }

  try {
    // Gabungkan kategori ke dalam deskripsi agar tersimpan dengan konteks
    const fullDescription = category
      ? `[Kategori: ${category}]\n${description}`
      : description;

    const result = await query(
      'INSERT INTO reports (name, email, description) VALUES ($1, $2, $3) RETURNING id',
      [name, email, fullDescription]
    );
    res.status(201).json({ message: 'Laporan berhasil dikirim', report_id: result.rows[0].id });
  } catch (error) {
    console.error('Error memproses laporan:', error.message);
    res.status(500).json({ error: 'Gagal menyimpan laporan ke database' });
  }
});

router.get('/reports', async (req, res) => {
  try {
    const result = await query('SELECT * FROM reports ORDER BY created_at DESC LIMIT 50');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Gagal mengambil data laporan' });
  }
});


router.post('/chat', upload.single('image'), async (req, res) => {
  try {
    const { message, lat, lon } = req.body;
    const imageBuffer = req.file ? req.file.buffer : null;
    const mimeType = req.file ? req.file.mimetype : null;

    if (!message && !imageBuffer) {
      return res.status(400).json({ error: "Pesan atau gambar harus ada, Juragan!" });
    }

    let weatherContext = "";
    if (lat && lon) {
      try {
        const weatherData = await getTodayData(null, parseFloat(lat), parseFloat(lon), null);
        weatherContext = `Konteks Lokasi Juragan: ${weatherData.location}. 
Kondisi Cuaca Saat Ini: ${weatherData.current.weather}, Suhu: ${weatherData.current.temperature}°C, Kelembaban: ${weatherData.current.humidity}%.
Peringatan/Insight: ${weatherData.alert || "Kondisi stabil"}.`;
      } catch (weatherError) {
        console.error("Weather Context Error:", weatherError.message);
      }
    }

    const response = await askTaniAI(message || "Apa yang bisa Anda lihat dari foto ini?", imageBuffer, mimeType, weatherContext);
    res.json({ response });
  } catch (error) {
    console.error("Chat Route Error:", error);
    res.status(500).json({ error: "Gagal ngobrol dengan AI." });
  }
});

export default router;
