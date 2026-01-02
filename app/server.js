const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const client = require('prom-client');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Prometheus metrics setup
const collectDefaultMetrics = client.collectDefaultMetrics;
const Registry = client.Registry;
const register = new Registry();
collectDefaultMetrics({ register });

// Custom metrics
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5],
  registers: [register]
});

const activeConnections = new client.Gauge({
  name: 'http_active_connections',
  help: 'Number of active HTTP connections',
  registers: [register]
});

const applicationInfo = new client.Gauge({
  name: 'application_info',
  help: 'Application information',
  labelNames: ['version', 'environment'],
  registers: [register]
});

// Set application info
applicationInfo.set({ version: '1.0.0', environment: NODE_ENV }, 1);

// Metrics middleware
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  activeConnections.inc();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    const labels = {
      method: req.method,
      route: route,
      status_code: res.statusCode
    };
    
    httpRequestsTotal.inc(labels);
    httpRequestDuration.observe(labels, duration);
    activeConnections.dec();
  });
  
  next();
};

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));

// Metrics middleware
app.use(metricsMiddleware);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

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

// Start server only if not in test environment
let server;
if (process.env.NODE_ENV !== 'test') {
  server = app.listen(PORT, () => {
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
}

module.exports = app;
