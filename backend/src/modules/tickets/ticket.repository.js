const prisma = require('../../utils/prisma');

const ticketInclude = {
  district: { select: { id: true, name: true } },
  tehsil: { select: { id: true, name: true } },
  project: { select: { id: true, name: true, description: true } },
  citizen: { select: { id: true, fullName: true, mobileNumber: true, email: true } },
  attachments: true,
  comments: {
    orderBy: { createdAt: 'asc' },
    include: {
      user: { select: { id: true, fullName: true, role: true } },
    },
  },
};

class TicketRepository {
  async generateTicketNumber() {
    const year = new Date().getFullYear();
    const count = await prisma.ticket.count({
      where: {
        createdAt: {
          gte: new Date(`${year}-01-01`),
          lt: new Date(`${year + 1}-01-01`),
        },
      },
    });
    return `TKT-${year}${String(count + 1).padStart(4, '0')}`;
  }

  async create(data) {
    const ticketNumber = await this.generateTicketNumber();
    return prisma.ticket.create({
      data: { ...data, ticketNumber },
      include: ticketInclude,
    });
  }

  async findById(id) {
    return prisma.ticket.findUnique({
      where: { id },
      include: ticketInclude,
    });
  }

  async findMany(where, { page = 1, limit = 20 } = {}) {
    const skip = (page - 1) * limit;
    const [tickets, total] = await Promise.all([
      prisma.ticket.findMany({
        where,
        include: {
          district: { select: { id: true, name: true } },
          tehsil: { select: { id: true, name: true } },
          project: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.ticket.count({ where }),
    ]);
    return { tickets, total, page, limit };
  }

  async updateStatus(id, data) {
    return prisma.ticket.update({
      where: { id },
      data,
      include: ticketInclude,
    });
  }

  async assign(id, agentId) {
    return prisma.ticket.update({
      where: { id },
      data: { assignedAgentId: agentId, status: 'ASSIGNED' },
      include: ticketInclude,
    });
  }

  async addComment(ticketId, userId, message) {
    return prisma.ticketComment.create({
      data: { ticketId, userId, message },
      include: {
        user: { select: { id: true, fullName: true, role: true } },
      },
    });
  }

  async addAttachments(ticketId, files) {
    return prisma.attachment.createMany({
      data: files.map((f) => ({
        ticketId,
        fileName: f.fileName,
        fileUrl: f.fileUrl,
        fileSize: f.fileSize,
      })),
    });
  }

  async getAnalytics() {
    const [byStatus, byPriority, total] = await Promise.all([
      prisma.ticket.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.ticket.groupBy({ by: ['priority'], _count: { id: true } }),
      prisma.ticket.count(),
    ]);
    return { byStatus, byPriority, total };
  }
}

module.exports = { TicketRepository, ticketInclude };
