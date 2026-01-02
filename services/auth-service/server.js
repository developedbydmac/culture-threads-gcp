const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const cors = require('cors');
const helmet = require('helmet');
const client = require('prom-client');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'culture-threads-secret-key';

// Prometheus metrics setup
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const authRequests = new client.Counter({
  name: 'auth_requests_total',
  help: 'Total authentication requests',
  labelNames: ['method', 'status'],
  registers: [register]
});

const activeUsers = new client.Gauge({
  name: 'auth_active_users',
  help: 'Number of active authenticated users',
  registers: [register]
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// In-memory user store (replace with database in production)
const users = new Map();
users.set('admin@culture-threads.com', {
  id: '1',
  email: 'admin@culture-threads.com',
  password: '$2b$10$8K1p/a0drtIIR1Hd6HMU4OzStkqJ4H4/qPF7mfxZeUBUr5qHqJ4.W', // 'admin123'
  role: 'admin',
  profile: {
    name: 'Culture Admin',
    culturalBackground: 'Multicultural',
    location: 'Global'
  }
});

users.set('user@culture-threads.com', {
  id: '2',
  email: 'user@culture-threads.com',
  password: '$2b$10$8K1p/a0drtIIR1Hd6HMU4OzStkqJ4H4/qPF7mfxZeUBUr5qHqJ4.W', // 'user123'
  role: 'user',
  profile: {
    name: 'Culture Enthusiast',
    culturalBackground: 'Various',
    location: 'Worldwide'
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'culture-threads-auth',
    timestamp: new Date().toISOString()
  });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Login endpoint
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      authRequests.inc({ method: 'login', status: 'error' });
      return res.status(400).json({ error: 'Email and password required' });
    }

    const user = users.get(email);
    if (!user) {
      authRequests.inc({ method: 'login', status: 'unauthorized' });
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      authRequests.inc({ method: 'login', status: 'unauthorized' });
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        role: user.role 
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    authRequests.inc({ method: 'login', status: 'success' });
    activeUsers.inc();

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        profile: user.profile
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    authRequests.inc({ method: 'login', status: 'error' });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Token validation endpoint
app.get('/auth/verify', authenticateToken, (req, res) => {
  authRequests.inc({ method: 'verify', status: 'success' });
  res.json({ 
    valid: true, 
    user: req.user 
  });
});

// User profile endpoint
app.get('/auth/profile', authenticateToken, (req, res) => {
  const user = users.get(req.user.email);
  if (user) {
    res.json(user.profile);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

// Logout endpoint
app.post('/auth/logout', authenticateToken, (req, res) => {
  authRequests.inc({ method: 'logout', status: 'success' });
  activeUsers.dec();
  res.json({ message: 'Logged out successfully' });
});

// Authentication middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    authRequests.inc({ method: 'verify', status: 'unauthorized' });
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      authRequests.inc({ method: 'verify', status: 'unauthorized' });
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

// Start server only if not in test mode
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🔐 Culture Threads Auth Service running on port ${PORT}`);
  });
}

module.exports = app;
