// backend/app.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Health check route
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
      serverTime: result.rows[0].now
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Database connection failed' });
  }
});

const authRoutes = require('./src/routes/authRoutes');
const expenseRoutes = require('./src/routes/expenseRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);

const authMiddleware = require('./src/middleware/authMiddleware');

// Protected test route
app.get('/api/protected', authMiddleware, (req, res) => {
  res.json({ 
    message: 'You accessed a protected route!', 
    user: req.user 
  });
});

// Global error handler (placeholder)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

module.exports = app;