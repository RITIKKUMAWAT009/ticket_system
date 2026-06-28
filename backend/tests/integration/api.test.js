const request = require('supertest');
const { createApp } = require('../../src/app');

const app = createApp();

describe('Health Check', () => {
  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('Auth Routes', () => {
  test('GET /api/auth/captcha returns captcha challenge', async () => {
    const res = await request(app).get('/api/auth/captcha');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.captchaToken).toBeDefined();
    expect(res.body.data.captchaQuestion).toBeDefined();
  });

  test('POST /api/auth/register validates input', async () => {
    const res = await request(app).post('/api/auth/register').send({
      registrationType: 'INDIAN',
      mobileNumber: '123',
      fullName: 'A',
    });
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('POST /api/auth/send-otp rejects invalid captcha', async () => {
    const res = await request(app).post('/api/auth/send-otp').send({
      mobileNumber: '9876543210',
      captchaToken: 'invalid-token',
      captchaAnswer: 'wrong',
    });
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('GET /api/auth/me requires authentication', async () => {
    const res = await request(app).get('/api/auth/me');
    expect(res.status).toBe(401);
  });
});

describe('Protected Routes', () => {
  test('GET /api/districts requires authentication', async () => {
    const res = await request(app).get('/api/districts');
    expect(res.status).toBe(401);
  });

  test('GET /api/tickets requires authentication', async () => {
    const res = await request(app).get('/api/tickets');
    expect(res.status).toBe(401);
  });

  test('GET /api/notifications requires authentication', async () => {
    const res = await request(app).get('/api/notifications');
    expect(res.status).toBe(401);
  });
});

describe('Swagger', () => {
  test('GET /api-docs.json returns OpenAPI spec', async () => {
    const res = await request(app).get('/api-docs.json');
    expect(res.status).toBe(200);
    expect(res.body.openapi).toBe('3.0.0');
    expect(res.body.info.title).toBe('Ticket Management System API');
  });
});

describe('404 Handler', () => {
  test('returns 404 for unknown routes', async () => {
    const res = await request(app).get('/api/unknown-route');
    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
  });
});
