require('dotenv').config();

module.exports = {
  port: parseInt(process.env.PORT, 10) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000',
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET,
    refreshSecret: process.env.JWT_REFRESH_SECRET,
    accessExpiry: process.env.JWT_ACCESS_EXPIRY || '15m',
    refreshExpiry: process.env.JWT_REFRESH_EXPIRY || '7d',
  },
  otp: {
    expiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES, 10) || 5,
    length: parseInt(process.env.OTP_LENGTH, 10) || 6,
  },
  upload: {
    dir: process.env.UPLOAD_DIR || './uploads',
    maxFileSizeMb: parseInt(process.env.MAX_FILE_SIZE_MB, 10) || 2,
    allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'],
    allowedExtensions: ['.jpg', '.jpeg', '.png', '.pdf'],
  },
  fcm: {
    disabled: process.env.FCM_DISABLED === 'true',
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH,
  },
  cors: {
    origin: (process.env.CORS_ORIGIN || 'http://localhost:8080').split(','),
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 900000,
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10) || 100,
  },
  captcha: {
    expiryMinutes: parseInt(process.env.CAPTCHA_EXPIRY_MINUTES, 10) || 10,
  },
};
