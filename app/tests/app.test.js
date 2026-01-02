const request = require('supertest');
const app = require('../server');

describe('Culture Threads API', () => {
  describe('GET /', () => {
    it('should return API information', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);
      
      expect(response.body).toHaveProperty('name', 'Culture Threads API');
      expect(response.body).toHaveProperty('version', '1.0.0');
      expect(response.body).toHaveProperty('status', 'running');
      expect(response.body).toHaveProperty('endpoints');
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);
      
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
    });
  });

  describe('GET /api/threads', () => {
    it('should return threads data', async () => {
      const response = await request(app)
        .get('/api/threads')
        .expect(200);
      
      expect(response.body).toHaveProperty('message', 'Culture Threads API');
      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
      
      // Check first thread structure
      const firstThread = response.body.data[0];
      expect(firstThread).toHaveProperty('id');
      expect(firstThread).toHaveProperty('title');
      expect(firstThread).toHaveProperty('content');
      expect(firstThread).toHaveProperty('author');
      expect(firstThread).toHaveProperty('timestamp');
      expect(firstThread).toHaveProperty('tags');
    });
  });

  describe('GET /invalid-route', () => {
    it('should return 404 for invalid routes', async () => {
      const response = await request(app)
        .get('/invalid-route')
        .expect(404);
      
      expect(response.body).toHaveProperty('error', 'Route not found');
      expect(response.body).toHaveProperty('path', '/invalid-route');
    });
  });
});
