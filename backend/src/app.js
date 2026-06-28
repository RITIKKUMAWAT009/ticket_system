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

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(
    cors({
      origin: (origin, callback) => {
        if (config.nodeEnv !== 'production') {
          return callback(null, true);
        }
        if (!origin || config.cors.origin.includes(origin)) {
          return callback(null, true);
        }
        return callback(new Error('Not allowed by CORS'));
      },
      credentials: true,
    })
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true }));

  const limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.max,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests, please try again later' },
  });
  app.use('/api/', limiter);

  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
    message: { success: false, message: 'Too many auth attempts' },
  });
  app.use('/api/auth/send-otp', authLimiter);
  app.use('/api/auth/verify-otp', authLimiter);

  app.use('/uploads', express.static(path.resolve(config.upload.dir)));

  app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  app.get('/api-docs.json', (_req, res) => res.json(swaggerSpec));

  app.use('/api/auth', authRoutes);
  app.use('/api', masterDataRoutes);
  app.use('/api/tickets', ticketRoutes);
  app.use('/api/notifications', notificationRoutes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  initFirebase();

  return app;
}

module.exports = { createApp };
