const { Router } = require('express');
const { NotificationService } = require('./notification.service');
const { authenticate } = require('../../middleware/auth');
const { validate } = require('../../middleware/errorHandler');
const { registerDeviceSchema } = require('../auth/auth.dto');

const router = Router();
const service = new NotificationService();

/**
 * @swagger
 * /notifications:
 *   get:
 *     summary: Get user notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 */
router.get('/', authenticate, async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const result = await service.list(req.user.id, { page, limit });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /notifications/{id}/read:
 *   patch:
 *     summary: Mark notification as read
 *     tags: [Notifications]
 */
router.patch('/:id/read', authenticate, async (req, res, next) => {
  try {
    const result = await service.markRead(req.params.id, req.user.id);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /notifications/read-all:
 *   patch:
 *     summary: Mark all notifications as read
 *     tags: [Notifications]
 */
router.patch('/read-all', authenticate, async (req, res, next) => {
  try {
    const result = await service.markAllRead(req.user.id);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

router.post(
  '/device-token',
  authenticate,
  validate(registerDeviceSchema),
  async (req, res, next) => {
    try {
      const { fcmToken, platform } = req.validated.body;
      const token = await service.registerDevice(req.user.id, fcmToken, platform);
      res.status(201).json({ success: true, data: token });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
