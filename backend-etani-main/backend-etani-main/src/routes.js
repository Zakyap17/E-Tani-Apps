import { Router } from 'express';
import { getTodayData } from './service.js';
import { query } from './db.js';

const router = Router();

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
    const data = await getTodayData(city, lat, lon);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

router.post('/report', async (req, res) => {
  const { name, email, description } = req.body;
  if (!name || !email || !description) {
    return res.status(400).json({ error: 'Semua field (name, email, description) harus diisi' });
  }

  try {
    const result = await query(
      'INSERT INTO reports (name, email, description) VALUES ($1, $2, $3) RETURNING id',
      [name, email, description]
    );
    res.status(201).json({ message: 'Laporan berhasil dikirim', report_id: result.rows[0].id });
  } catch (error) {
    console.error('Error memproses laporan:', error.message);
    res.status(500).json({ error: 'Gagal menyimpannya di database' });
  }
});

export default router;
