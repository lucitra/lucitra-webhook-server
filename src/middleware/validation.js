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

    // Check for HubSpot v3 signature
    const signatureV3 = req.headers['x-hubspot-signature-v3'];
    const timestamp = req.headers['x-hubspot-request-timestamp'];
    
    if (!signatureV3 || !timestamp) {
      logger.warn('Missing webhook signature or timestamp');
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Get webhook secret from environment
    const secret = process.env.HUBSPOT_WEBHOOK_SECRET;
    
    if (!secret) {
      logger.error('HUBSPOT_WEBHOOK_SECRET not configured');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    // Validate timestamp (prevent replay attacks)
    const currentTime = Date.now();
    const webhookTime = parseInt(timestamp) * 1000; // Convert to milliseconds
    const timeDiff = Math.abs(currentTime - webhookTime);
    
    if (timeDiff > 300000) { // 5 minutes
      logger.warn('Webhook timestamp too old', { timeDiff });
      return res.status(401).json({ error: 'Request timestamp too old' });
    }

    // Validate v3 signature
    const method = req.method;
    const uri = `https://${req.headers.host}${req.originalUrl}`;
    const body = JSON.stringify(req.body);
    const sourceString = method + uri + body + timestamp;
    
    const hash = crypto.createHmac('sha256', secret)
      .update(sourceString, 'utf8')
      .digest('base64');
    
    if (hash !== signatureV3) {
      logger.warn('Invalid webhook signature');
      return res.status(401).json({ error: 'Invalid signature' });
    }

    logger.info('Webhook signature validated successfully');
    next();
  } catch (error) {
    logger.error('Webhook validation error:', error);
    res.status(400).json({ error: 'Invalid request' });
  }
};

module.exports = { validateWebhook };