const { ZodError } = require('zod');
const logger = require('../utils/logger');

function validate(schema) {
  return (req, res, next) => {
    try {
      req.validated = schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: error.errors.map((e) => ({
            field: e.path.join('.'),
            message: e.message,
          })),
        });
      }
      next(error);
    }
  };
}

function errorHandler(err, req, res, _next) {
  logger.error('Request error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  if (err.name === 'UnauthorizedError' || err.status === 401) {
    return res.status(401).json({ success: false, message: err.message || 'Unauthorized' });
  }

  if (err.status === 403) {
    return res.status(403).json({ success: false, message: err.message || 'Forbidden' });
  }

  if (err.status === 404) {
    return res.status(404).json({ success: false, message: err.message || 'Not found' });
  }

  const status = err.status || 500;
  const message =
    process.env.NODE_ENV === 'production' && status === 500
      ? 'Internal server error'
      : err.message;

  res.status(status).json({ success: false, message });
}

function notFoundHandler(req, res) {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found` });
}

module.exports = { validate, errorHandler, notFoundHandler };
