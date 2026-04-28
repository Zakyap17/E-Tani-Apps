import express from 'express';
import routes from './routes.js';
import dotenv from "dotenv";
import cors from 'cors';
import { initDb } from './db.js';

dotenv.config();

// Iniasilisasi struktur tabel PostgreSQL
initDb();

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

app.use('/', routes);

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
