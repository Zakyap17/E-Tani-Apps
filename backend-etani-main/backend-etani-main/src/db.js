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
    
    console.log("Database initialized: Table 'reports' is ready.");
    client.release();
  } catch (error) {
    console.error("Error initializing Database PostgreSQL: ", error.message);
  }
};

export const query = (text, params) => pool.query(text, params);
