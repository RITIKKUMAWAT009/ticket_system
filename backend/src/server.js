const { createApp } = require('./app');
const config = require('./config');
const logger = require('./utils/logger');

const app = createApp();

const PORT = process.env.PORT || config.port || 3000;

app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Server running on port ${PORT}`);
  logger.info(`Swagger docs: ${config.apiBaseUrl}/api-docs`);
  logger.info(`Environment: ${config.nodeEnv}`);
});

module.exports = app;
