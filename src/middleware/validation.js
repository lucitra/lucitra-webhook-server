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

    // For HubSpot v3 webhooks with the new project system
    // Signature validation is handled differently
    
    // Check if this is a HubSpot webhook by looking for expected headers
    const hubspotHeaders = [
      'x-hubspot-request-timestamp',
      'x-hubspot-signature-v3',
      'x-hubspot-signature'
    ];
    
    const hasHubSpotHeaders = hubspotHeaders.some(header => req.headers[header]);
    
    if (hasHubSpotHeaders) {
      logger.info('HubSpot webhook detected', {
        timestamp: req.headers['x-hubspot-request-timestamp'],
        hasV3Signature: !!req.headers['x-hubspot-signature-v3'],
        hasLegacySignature: !!req.headers['x-hubspot-signature']
      });
      
      // For now, accept all HubSpot webhooks
      // TODO: Implement proper v3 signature validation when secret is available
      logger.warn('Webhook signature validation skipped - implement when secret is configured');
    }

    next();
  } catch (error) {
    logger.error('Webhook validation error:', error);
    res.status(400).json({ error: 'Invalid request' });
  }
};

module.exports = { validateWebhook };