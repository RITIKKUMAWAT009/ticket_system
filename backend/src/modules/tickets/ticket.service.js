const { TicketRepository } = require('./ticket.repository');
const { NotificationService } = require('../notifications/notification.service');

class TicketService {
  constructor(
    repository = new TicketRepository(),
    notificationService = new NotificationService()
  ) {
    this.repository = repository;
    this.notificationService = notificationService;
  }

  _buildAccessFilter(user) {
    if (user.role === 'CITIZEN') {
      return { citizenId: user.id };
    }
    if (user.role === 'SUPPORT_AGENT') {
      return { assignedAgentId: user.id };
    }
    return {};
  }

  async canAccessTicket(ticket, user) {
    if (user.role === 'ADMIN') return true;
    if (user.role === 'CITIZEN' && ticket.citizenId === user.id) return true;
    if (user.role === 'SUPPORT_AGENT' && ticket.assignedAgentId === user.id) return true;
    return false;
  }

  async create(citizenId, data, attachments = []) {
    const ticket = await this.repository.create({
      citizenId,
      districtId: data.districtId,
      tehsilId: data.tehsilId,
      projectId: data.projectId,
      remarks: data.remarks,
    });

    if (attachments.length > 0) {
      await this.repository.addAttachments(ticket.id, attachments);
    }

    const fullTicket = await this.repository.findById(ticket.id);
    await this.notificationService.notifyTicketCreated(fullTicket, citizenId);
    return fullTicket;
  }

  async list(user, query = {}) {
    const where = this._buildAccessFilter(user);
    if (query.status) where.status = query.status;
    return this.repository.findMany(where, query);
  }

  async getById(id, user) {
    const ticket = await this.repository.findById(id);
    if (!ticket) {
      const error = new Error('Ticket not found');
      error.status = 404;
      throw error;
    }
    if (!(await this.canAccessTicket(ticket, user))) {
      const error = new Error('Access denied');
      error.status = 403;
      throw error;
    }
    return ticket;
  }

  async updateStatus(id, user, { status, priority }) {
    const ticket = await this.repository.findById(id);
    if (!ticket) {
      const error = new Error('Ticket not found');
      error.status = 404;
      throw error;
    }

    if (user.role === 'CITIZEN') {
      const error = new Error('Citizens cannot change ticket status');
      error.status = 403;
      throw error;
    }

    if (user.role === 'SUPPORT_AGENT' && ticket.assignedAgentId !== user.id) {
      const error = new Error('Access denied');
      error.status = 403;
      throw error;
    }

    const updateData = { status };
    if (priority) updateData.priority = priority;

    const updated = await this.repository.updateStatus(id, updateData);

    if (status === 'CLOSED') {
      await this.notificationService.notifyTicketClosed(updated);
    } else if (status === 'REOPENED') {
      await this.notificationService.notifyTicketReopened(updated);
    } else {
      await this.notificationService.notifyStatusChanged(updated, status);
    }

    return updated;
  }

  async assign(id, agentId) {
    const ticket = await this.repository.findById(id);
    if (!ticket) {
      const error = new Error('Ticket not found');
      error.status = 404;
      throw error;
    }

    const updated = await this.repository.assign(id, agentId);
    await this.notificationService.notifyTicketAssigned(updated, agentId);
    return updated;
  }

  async addComment(ticketId, user, message) {
    const ticket = await this.repository.findById(ticketId);
    if (!ticket) {
      const error = new Error('Ticket not found');
      error.status = 404;
      throw error;
    }

    if (!(await this.canAccessTicket(ticket, user))) {
      const error = new Error('Access denied');
      error.status = 403;
      throw error;
    }

    const comment = await this.repository.addComment(ticketId, user.id, message);
    await this.notificationService.notifyCommentAdded(ticket, user.id, user.fullName);
    return comment;
  }

  async getAnalytics() {
    return this.repository.getAnalytics();
  }
}

module.exports = { TicketService };
