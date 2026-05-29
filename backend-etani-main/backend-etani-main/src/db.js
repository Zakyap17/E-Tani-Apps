import pg from 'pg';

const { Pool } = pg;

// Konfigurasi koneksi dari Environment Variable (Docker-Compose)
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'etani',
  port: process.env.DB_PORT || 5432,
});

export const initDb = async () => {
  try {
    const client = await pool.connect();
    
    // Auto-create table reports
    await client.query(`
      CREATE TABLE IF NOT EXISTS reports (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Auto-create table blocks (Manajemen Blok Lahan Dinamis)
    await client.query(`
      CREATE TABLE IF NOT EXISTS blocks (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        crop_type VARCHAR(255) NOT NULL,
        planting_date DATE NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    console.log("Database initialized: Tables 'reports' and 'blocks' are ready.");
    client.release();
  } catch (error) {
    console.error("Error initializing Database PostgreSQL: ", error.message);
  }
};

export const query = (text, params) => pool.query(text, params);
