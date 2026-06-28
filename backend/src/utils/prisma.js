const { PrismaClient } = require('@prisma/client');
const logger = require('./logger');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

prisma.$connect().catch((err) => {
  logger.error('Failed to connect to database', { error: err.message });
});

module.exports = prisma;
