const { createApp } = require('./app');
const config = require('./config');
const logger = require('./utils/logger');

const app = createApp();

if (require.main === module) {
  app.listen(config.port, () => {
    logger.info(`Server running on port ${config.port}`);
    logger.info(`Swagger docs: ${config.apiBaseUrl}/api-docs`);
    logger.info(`Environment: ${config.nodeEnv}`);
  });
}

module.exports = app;
