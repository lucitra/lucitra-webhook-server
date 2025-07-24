const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// In production, add Cloud Logging
if (process.env.NODE_ENV === 'production') {
  const { LoggingWinston } = require('@google-cloud/logging-winston');
  logger.add(new LoggingWinston());
}

module.exports = { logger };