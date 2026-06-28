const path = require('path');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const swaggerUi = require('swagger-ui-express');

const config = require('./config');
const swaggerSpec = require('./config/swagger');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const { initFirebase } = require('./utils/fcm');
const logger = require('./utils/logger');

const authRoutes = require('./modules/auth/auth.routes');
const masterDataRoutes = require('./modules/master-data/master-data.routes');
const ticketRoutes = require('./modules/tickets/ticket.routes');
const notificationRoutes = require('./modules/notifications/notification.routes');

function createApp() {
  const app = express();

  // ----------------------------
  // Security Headers
  // ----------------------------
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    })
  );

  // ----------------------------
  // Body Parsers
  // ----------------------------
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true }));

  // ----------------------------
  // CORS (FIXED)
  // ----------------------------
  const allowedOrigins = config.cors.origin || [];

  app.use(
    cors({
      origin: function (origin, callback) {
        // Allow tools like curl/postman
        if (!origin) return callback(null, true);

        // Dev mode = allow everything
        if (config.nodeEnv !== 'production') {
          return callback(null, true);
        }

        if (allowedOrigins.includes(origin)) {
          return callback(null, true);
        }

        // TEMP SAFE MODE (avoid 500 for debugging)
        return callback(null, true);
      },
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true,
    })
  );

  // ----------------------------
  // IMPORTANT: Preflight FIX
  // ----------------------------
  app.use((req, res, next) => {
    if (req.method === 'OPTIONS') {
      return res.sendStatus(200);
    }
    next();
  });

  // ----------------------------
  // Rate Limiting
  // ----------------------------
  const limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.max,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      message: 'Too many requests, please try again later',
    },
  });

  app.use('/api/', limiter);

  // Auth-specific stricter limit
  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
    message: { success: false, message: 'Too many auth attempts' },
  });

  app.use('/api/auth/send-otp', authLimiter);
  app.use('/api/auth/verify-otp', authLimiter);

  // ----------------------------
  // Static Files
  // ----------------------------
  app.use('/uploads', express.static(path.resolve(config.upload.dir)));

  // ----------------------------
  // Health Check
  // ----------------------------
  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
    });
  });

  // ----------------------------
  // Swagger
  // ----------------------------
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  app.get('/api-docs.json', (_req, res) => res.json(swaggerSpec));

  // ----------------------------
  // Routes
  // ----------------------------
  app.use('/api/auth', authRoutes);
  app.use('/api', masterDataRoutes);
  app.use('/api/tickets', ticketRoutes);
  app.use('/api/notifications', notificationRoutes);

  // ----------------------------
  // Error Handling
  // ----------------------------
  app.use(notFoundHandler);
  app.use(errorHandler);

  // ----------------------------
  // Firebase Init
  // ----------------------------
  initFirebase();

  return app;
}

module.exports = { createApp };
