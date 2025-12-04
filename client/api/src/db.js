const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: Number(process.env.PGPORT) || 5432,
  user: process.env.PGUSER || 'controlpay',
  password: process.env.PGPASSWORD || 'C0ntr4lP4y!',
  database: process.env.PGDATABASE || 'controlpaydb',
});

pool.on('error', (err) => {
  console.error('Unexpected PG error', err);
});

module.exports = { pool };
