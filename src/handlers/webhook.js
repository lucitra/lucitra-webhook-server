const { logger } = require('../utils/logger');
const { processWebhookEvent } = require('../services/webhook-processor');

const handleWebhook = async (req, res) => {
  try {
    const { eventType, objectId, objectType, portalId } = req.body;

    logger.info('Processing webhook event:', {
      eventType,
      objectId,
      objectType,
      portalId
    });

    // Process webhook asynchronously
    processWebhookEvent(req.body).catch(error => {
      logger.error('Error processing webhook:', error);
    });

    // Respond immediately to HubSpot
    res.status(200).json({ status: 'received' });
  } catch (error) {
    logger.error('Webhook handler error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { handleWebhook };