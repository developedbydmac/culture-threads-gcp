const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    environment: NODE_ENV
  });
});

// API routes
app.get('/api/threads', (req, res) => {
  res.json({
    message: 'Culture Threads API',
    data: [
      {
        id: 1,
        title: 'Welcome to Culture Threads',
        content: 'A platform for sharing cultural stories and experiences',
        author: 'Community',
        timestamp: new Date().toISOString(),
        tags: ['welcome', 'community', 'culture']
      },
      {
        id: 2,
        title: 'Share Your Story',
        content: 'Tell us about your cultural background and traditions',
        author: 'Moderator',
        timestamp: new Date().toISOString(),
        tags: ['story', 'tradition', 'sharing']
      }
    ]
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Culture Threads API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      threads: '/api/threads'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`🚀 Culture Threads API running on port ${PORT}`);
  console.log(`📊 Environment: ${NODE_ENV}`);
  console.log(`🌍 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

module.exports = app;
