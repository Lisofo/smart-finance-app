// backend/src/config/db.js
const { Pool } = require('pg');

const port = parseInt(process.env.DB_PORT || '5432', 10);

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number.isFinite(port) ? port : 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD ?? '',
  database: process.env.DB_NAME || 'smart_finance',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

pool.on('connect', () => {
  if (process.env.NODE_ENV !== 'production') {
    console.log('[db] client connected to PostgreSQL');
  }
});

pool.on('error', (err) => {
  console.error('[db] unexpected pool error', err.message);
});

module.exports = pool;