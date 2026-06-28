const { Router } = require('express');
const { AuthService } = require('./auth.service');
const { validate } = require('../../middleware/errorHandler');
const { authenticate } = require('../../middleware/auth');
const {
  registerSchema,
  sendOtpSchema,
  verifyOtpSchema,
  refreshTokenSchema,
} = require('./auth.dto');
const { generateCaptcha } = require('../../utils/captcha');

const router = Router();
const authService = new AuthService();

/**
 * @swagger
 * /auth/captcha:
 *   get:
 *     summary: Get a new captcha challenge
 *     tags: [Auth]
 *     responses:
 *       200:
 *         description: Captcha challenge
 */
router.get('/captcha', (_req, res) => {
  const captcha = generateCaptcha();
  res.json({ success: true, data: captcha });
});

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new citizen (Indian or NRI)
 *     tags: [Auth]
 */
router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const result = await authService.register(req.validated.body);
    res.status(201).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /auth/send-otp:
 *   post:
 *     summary: Send OTP to registered mobile number
 *     tags: [Auth]
 */
router.post('/send-otp', validate(sendOtpSchema), async (req, res, next) => {
  try {
    const result = await authService.sendOtp(req.validated.body);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /auth/verify-otp:
 *   post:
 *     summary: Verify OTP and receive JWT tokens
 *     tags: [Auth]
 */
router.post('/verify-otp', validate(verifyOtpSchema), async (req, res, next) => {
  try {
    const result = await authService.verifyOtp(req.validated.body);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Refresh access token
 *     tags: [Auth]
 */
router.post('/refresh', validate(refreshTokenSchema), async (req, res, next) => {
  try {
    const tokens = await authService.refresh(req.validated.body.refreshToken);
    res.json({ success: true, data: tokens });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Get current authenticated user
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 */
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const user = await authService.getMe(req.user.id);
    res.json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
