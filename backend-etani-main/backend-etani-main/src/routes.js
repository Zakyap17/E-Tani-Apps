import { Router } from 'express';
import { getTodayData } from './service.js';

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
    const data = await getTodayData(city);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
