import { Router } from 'express';
import multer from 'multer';
import { getTodayData } from './service.js';
import { query } from './db.js';
import { askTaniAI } from './aiService.js';
import { generateTasksForBlock } from './scheduleService.js';

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

// ============================================================
// MANAJEMEN BLOK LAHAN (CRUD)
// ============================================================

// GET /blocks — Ambil semua blok lahan aktif
router.get('/blocks', async (req, res) => {
  try {
    const result = await query(
      'SELECT * FROM blocks ORDER BY created_at ASC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error mengambil blok:', error.message);
    res.status(500).json({ error: 'Gagal mengambil data blok' });
  }
});

// POST /blocks — Tambah blok lahan baru
router.post('/blocks', async (req, res) => {
  const { name, crop_type, planting_date } = req.body;
  if (!name || !crop_type || !planting_date) {
    return res.status(400).json({ error: 'Nama blok, jenis tanaman, dan tanggal tanam wajib diisi' });
  }
  try {
    const result = await query(
      'INSERT INTO blocks (name, crop_type, planting_date, status) VALUES ($1, $2, $3, $4) RETURNING *',
      [name.trim(), crop_type.trim(), planting_date, 'active']
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error menambah blok:', error.message);
    res.status(500).json({ error: 'Gagal menambahkan blok' });
  }
});

// PUT /blocks/:id — Edit blok lahan
router.put('/blocks/:id', async (req, res) => {
  const { id } = req.params;
  const { name, crop_type, planting_date, status } = req.body;
  if (!name || !crop_type || !planting_date) {
    return res.status(400).json({ error: 'Nama blok, jenis tanaman, dan tanggal tanam wajib diisi' });
  }
  try {
    const result = await query(
      'UPDATE blocks SET name=$1, crop_type=$2, planting_date=$3, status=$4 WHERE id=$5 RETURNING *',
      [name.trim(), crop_type.trim(), planting_date, status || 'active', id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Blok tidak ditemukan' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error mengedit blok:', error.message);
    res.status(500).json({ error: 'Gagal mengedit blok' });
  }
});

// DELETE /blocks/:id — Hapus blok lahan
router.delete('/blocks/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await query('DELETE FROM blocks WHERE id=$1 RETURNING id', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Blok tidak ditemukan' });
    }
    res.json({ message: 'Blok berhasil dihapus', id: result.rows[0].id });
  } catch (error) {
    console.error('Error menghapus blok:', error.message);
    res.status(500).json({ error: 'Gagal menghapus blok' });
  }
});

// ============================================================
// JADWAL DINAMIS PER BLOK
// ============================================================

// GET /schedule — Hasilkan jadwal harian adaptif per blok aktif
// Query params opsional: ?lat=xxx&lon=xxx (untuk cuaca lokasi pengguna)
router.get('/schedule', async (req, res) => {
  try {
    const lat = req.query.lat ? parseFloat(req.query.lat) : null;
    const lon = req.query.lon ? parseFloat(req.query.lon) : null;
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

    // Ambil data cuaca (gunakan koordinat atau IP)
    let weatherData = null;
    try {
      weatherData = await getTodayData(null, lat, lon, ip);
    } catch (weatherError) {
      console.error("Schedule - Weather fetch error:", weatherError.message);
    }

    // Ambil semua blok aktif dari DB
    const blocksResult = await query(
      "SELECT * FROM blocks WHERE status = 'active' ORDER BY created_at ASC"
    );
    const blocks = blocksResult.rows;

    if (blocks.length === 0) {
      return res.json({
        location: weatherData?.location ?? 'Tidak Diketahui',
        weather: weatherData?.current ?? null,
        alert: weatherData?.alert ?? null,
        schedule: [],
        message: 'Belum ada blok lahan yang terdaftar. Tambahkan blok pertama Anda!',
      });
    }

    // Generate jadwal per blok
    const schedule = blocks.map(block => generateTasksForBlock(block, weatherData));

    res.json({
      location: weatherData?.location ?? 'Tidak Diketahui',
      weather: weatherData?.current ?? null,
      alert: weatherData?.alert ?? null,
      schedule,
    });
  } catch (error) {
    console.error('Error mengambil jadwal:', error.message);
    res.status(500).json({ error: 'Gagal mengambil jadwal' });
  }
});

export default router;
