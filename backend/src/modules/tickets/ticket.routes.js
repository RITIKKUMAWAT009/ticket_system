const { Router } = require('express');
const { TicketService } = require('./ticket.service');
const { authenticate, authorize } = require('../../middleware/auth');
const { validate } = require('../../middleware/errorHandler');
const { upload, mapUploadedFiles } = require('../../middleware/upload');
const {
  createTicketSchema,
  updateStatusSchema,
  assignTicketSchema,
  addCommentSchema,
} = require('../auth/auth.dto');
const config = require('../../config');

const router = Router();
const ticketService = new TicketService();

/**
 * @swagger
 * /tickets:
 *   post:
 *     summary: Create a new ticket with optional attachments
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/',
  authenticate,
  authorize('CITIZEN'),
  upload.array('attachments', 5),
  validate(createTicketSchema),
  async (req, res, next) => {
    try {
      const baseUrl = config.apiBaseUrl;
      const attachments = mapUploadedFiles(req.files, baseUrl);
      const ticket = await ticketService.create(
        req.user.id,
        req.validated.body,
        attachments
      );
      res.status(201).json({ success: true, data: ticket });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /tickets:
 *   get:
 *     summary: List tickets (filtered by role)
 *     tags: [Tickets]
 */
router.get('/', authenticate, async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const status = req.query.status || undefined;
    const result = await ticketService.list(req.user, { page, limit, status });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /tickets/analytics:
 *   get:
 *     summary: Ticket analytics (Admin only)
 *     tags: [Tickets]
 */
router.get('/analytics', authenticate, authorize('ADMIN'), async (_req, res, next) => {
  try {
    const analytics = await ticketService.getAnalytics();
    res.json({ success: true, data: analytics });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /tickets/{id}:
 *   get:
 *     summary: Get ticket details
 *     tags: [Tickets]
 */
router.get('/:id', authenticate, async (req, res, next) => {
  try {
    const ticket = await ticketService.getById(req.params.id, req.user);
    res.json({ success: true, data: ticket });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /tickets/{id}/status:
 *   patch:
 *     summary: Update ticket status
 *     tags: [Tickets]
 */
router.patch(
  '/:id/status',
  authenticate,
  authorize('SUPPORT_AGENT', 'ADMIN'),
  validate(updateStatusSchema),
  async (req, res, next) => {
    try {
      const ticket = await ticketService.updateStatus(
        req.params.id,
        req.user,
        req.validated.body
      );
      res.json({ success: true, data: ticket });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /tickets/{id}/assign:
 *   patch:
 *     summary: Assign ticket to support agent (Admin only)
 *     tags: [Tickets]
 */
router.patch(
  '/:id/assign',
  authenticate,
  authorize('ADMIN'),
  validate(assignTicketSchema),
  async (req, res, next) => {
    try {
      const ticket = await ticketService.assign(req.params.id, req.validated.body.agentId);
      res.json({ success: true, data: ticket });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /tickets/{id}/comments:
 *   post:
 *     summary: Add comment to ticket
 *     tags: [Tickets]
 */
router.post(
  '/:id/comments',
  authenticate,
  validate(addCommentSchema),
  async (req, res, next) => {
    try {
      const comment = await ticketService.addComment(
        req.params.id,
        req.user,
        req.validated.body.message
      );
      res.status(201).json({ success: true, data: comment });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
