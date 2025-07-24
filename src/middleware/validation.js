const crypto = require('crypto');
const { logger } = require('../utils/logger');

const validateWebhook = (req, res, next) => {
  try {
    // Log incoming webhook
    logger.info('Received webhook:', {
      method: req.method,
      path: req.path,
      headers: req.headers,
      body: req.body
    });

    // Validate HubSpot webhook signature if present
    if (req.headers['x-hubspot-signature']) {
      const signature = req.headers['x-hubspot-signature'];
      const timestamp = req.headers['x-hubspot-request-timestamp'];
      const secret = process.env.HUBSPOT_WEBHOOK_SECRET;

      if (!secret) {
        logger.warn('No webhook secret configured');
        return next();
      }

      // Verify signature
      const sourceString = req.method + req.url + JSON.stringify(req.body) + timestamp;
      const hash = crypto.createHmac('sha256', secret).update(sourceString).digest('hex');

      if (hash !== signature) {
        logger.error('Invalid webhook signature');
        return res.status(401).json({ error: 'Invalid signature' });
      }
    }

    next();
  } catch (error) {
    logger.error('Webhook validation error:', error);
    res.status(400).json({ error: 'Invalid request' });
  }
};

module.exports = { validateWebhook };