const prisma = require('../../utils/prisma');
const { sendPushNotification } = require('../../utils/fcm');
const logger = require('../../utils/logger');

class NotificationRepository {
  async create(data) {
    return prisma.notification.create({ data });
  }

  async findByUser(userId, { page = 1, limit = 20 } = {}) {
    const skip = (page - 1) * limit;
    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          ticket: { select: { id: true, ticketNumber: true, status: true } },
        },
      }),
      prisma.notification.count({ where: { userId } }),
    ]);
    return { notifications, total, page, limit };
  }

  async markAsRead(id, userId) {
    return prisma.notification.updateMany({
      where: { id, userId },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId) {
    return prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }

  async getUnreadCount(userId) {
    return prisma.notification.count({ where: { userId, isRead: false } });
  }

  async getDeviceTokens(userId) {
    return prisma.deviceToken.findMany({ where: { userId } });
  }

  async upsertDeviceToken(userId, fcmToken, platform) {
    return prisma.deviceToken.upsert({
      where: { fcmToken },
      update: { userId, platform },
      create: { userId, fcmToken, platform },
    });
  }
}

class NotificationService {
  constructor(repository = new NotificationRepository()) {
    this.repository = repository;
  }

  async notify(userId, title, body, ticketId = null) {
    const notification = await this.repository.create({
      userId,
      title,
      body,
      ticketId,
    });

    const tokens = await this.repository.getDeviceTokens(userId);
    await Promise.all(
      tokens.map((t) =>
        sendPushNotification(t.fcmToken, title, body, {
          notificationId: notification.id,
          ticketId: ticketId || '',
        })
      )
    );

    return notification;
  }

  async notifyTicketCreated(ticket, citizenId) {
    await this.notify(
      citizenId,
      'Ticket Created',
      `Your ticket ${ticket.ticketNumber} has been created successfully.`,
      ticket.id
    );
  }

  async notifyTicketAssigned(ticket, agentId) {
    await this.notify(
      agentId,
      'Ticket Assigned',
      `Ticket ${ticket.ticketNumber} has been assigned to you.`,
      ticket.id
    );
    await this.notify(
      ticket.citizenId,
      'Ticket Assigned',
      `Your ticket ${ticket.ticketNumber} has been assigned to a support agent.`,
      ticket.id
    );
  }

  async notifyStatusChanged(ticket, newStatus) {
    await this.notify(
      ticket.citizenId,
      'Status Updated',
      `Ticket ${ticket.ticketNumber} status changed to ${newStatus}.`,
      ticket.id
    );
    if (ticket.assignedAgentId) {
      await this.notify(
        ticket.assignedAgentId,
        'Status Updated',
        `Ticket ${ticket.ticketNumber} status changed to ${newStatus}.`,
        ticket.id
      );
    }
  }

  async notifyCommentAdded(ticket, commenterId, commenterName) {
    const recipients = new Set([ticket.citizenId]);
    if (ticket.assignedAgentId) recipients.add(ticket.assignedAgentId);
    recipients.delete(commenterId);

    await Promise.all(
      [...recipients].map((userId) =>
        this.notify(
          userId,
          'New Comment',
          `${commenterName} commented on ticket ${ticket.ticketNumber}.`,
          ticket.id
        )
      )
    );
  }

  async notifyTicketClosed(ticket) {
    await this.notify(
      ticket.citizenId,
      'Ticket Closed',
      `Your ticket ${ticket.ticketNumber} has been closed.`,
      ticket.id
    );
  }

  async notifyTicketReopened(ticket) {
    await this.notify(
      ticket.citizenId,
      'Ticket Reopened',
      `Your ticket ${ticket.ticketNumber} has been reopened.`,
      ticket.id
    );
    if (ticket.assignedAgentId) {
      await this.notify(
        ticket.assignedAgentId,
        'Ticket Reopened',
        `Ticket ${ticket.ticketNumber} has been reopened.`,
        ticket.id
      );
    }
  }

  async list(userId, query) {
    return this.repository.findByUser(userId, query);
  }

  async markRead(id, userId) {
    const result = await this.repository.markAsRead(id, userId);
    if (result.count === 0) {
      const error = new Error('Notification not found');
      error.status = 404;
      throw error;
    }
    return { message: 'Notification marked as read' };
  }

  async markAllRead(userId) {
    await this.repository.markAllAsRead(userId);
    return { message: 'All notifications marked as read' };
  }

  async registerDevice(userId, fcmToken, platform) {
    return this.repository.upsertDeviceToken(userId, fcmToken, platform);
  }
}

module.exports = { NotificationRepository, NotificationService };
