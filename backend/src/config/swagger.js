const swaggerJsdoc = require('swagger-jsdoc');
const config = require('../config');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Ticket Management System API',
      version: '1.0.0',
      description:
        'REST API for citizen complaint/ticket management with OTP authentication, FCM notifications, and role-based access.',
      contact: {
        name: 'API Support',
      },
    },
    servers: [
      { url: config.apiBaseUrl, description: 'Current environment' },
      { url: 'http://localhost:3000', description: 'Local development' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            mobileNumber: { type: 'string', example: '9876543210' },
            fullName: { type: 'string' },
            fatherName: { type: 'string' },
            email: { type: 'string', format: 'email' },
            aadhaarNumber: { type: 'string', nullable: true },
            passportNumber: { type: 'string', nullable: true },
            gender: { type: 'string', enum: ['MALE', 'FEMALE', 'OTHER'] },
            role: { type: 'string', enum: ['CITIZEN', 'SUPPORT_AGENT', 'ADMIN'] },
            profileImageUrl: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Ticket: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            ticketNumber: { type: 'string', example: 'TKT-20260001' },
            citizenId: { type: 'string', format: 'uuid' },
            districtId: { type: 'string', format: 'uuid' },
            tehsilId: { type: 'string', format: 'uuid' },
            projectId: { type: 'string', format: 'uuid' },
            remarks: { type: 'string' },
            status: {
              type: 'string',
              enum: ['OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED'],
            },
            priority: {
              type: 'string',
              enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
            },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        TicketComment: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            ticketId: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            message: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Notification: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            title: { type: 'string' },
            body: { type: 'string' },
            ticketId: { type: 'string', format: 'uuid', nullable: true },
            isRead: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        District: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            name: { type: 'string' },
          },
        },
        Tehsil: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            districtId: { type: 'string', format: 'uuid' },
            name: { type: 'string' },
          },
        },
        Project: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            tehsilId: { type: 'string', format: 'uuid' },
            name: { type: 'string' },
            description: { type: 'string', nullable: true },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: 'Authentication and registration' },
      { name: 'Master Data', description: 'Districts, tehsils, and projects' },
      { name: 'Tickets', description: 'Ticket management' },
      { name: 'Notifications', description: 'Push and in-app notifications' },
    ],
  },
  apis: ['./src/modules/**/*.routes.js'],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
