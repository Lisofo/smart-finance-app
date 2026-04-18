// backend/app.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();

function requireEnv() {
  const jwt = process.env.JWT_SECRET;
  if (!jwt || jwt.length < 16) {
    console.error(
      '[config] JWT_SECRET is missing or too short. Set JWT_SECRET in backend/.env (see .env.example).'
    );
    process.exit(1);
  }
}

requireEnv();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '1mb' }));

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

const pool = require('./src/config/db');

app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as now');
    res.json({
      success: true,
      message: 'Database connected',
      serverTime: result.rows[0].now,
    });
  } catch (err) {
    console.error('[db-test]', err.message);
    res.status(500).json({ success: false, message: 'Database connection failed' });
  }
});

const authRoutes = require('./src/routes/authRoutes');
const expenseRoutes = require('./src/routes/expenseRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);

const authMiddleware = require('./src/middleware/authMiddleware');

app.get('/api/protected', authMiddleware, (req, res) => {
  res.json({
    message: 'You accessed a protected route!',
    user: req.user,
  });
});

// Global error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('[error]', err.message);
  if (process.env.NODE_ENV !== 'production' && err.stack) {
    console.error(err.stack);
  }
  const status = err.status && Number.isFinite(err.status) ? err.status : 500;
  res.status(status).json({
    message: status === 500 ? 'Something went wrong' : err.message || 'Error',
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

const PORT = parseInt(process.env.PORT || '5000', 10);
app.listen(PORT, () => {
  console.log(`[server] listening on port ${PORT} (${process.env.NODE_ENV || 'development'})`);
});

module.exports = app;
