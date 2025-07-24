const { logger } = require('../utils/logger');
const { processWebhookEvent } = require('../services/webhook-processor');

const handleWebhook = async (req, res) => {
  try {
    // HubSpot sends webhook data in different formats depending on the version
    const webhookData = req.body;
    
    // Check if it's a batch of events (v3 format)
    if (Array.isArray(webhookData)) {
      logger.info(`Processing batch of ${webhookData.length} webhook events`);
      
      // Process each event in the batch
      for (const event of webhookData) {
        processWebhookEvent(event).catch(error => {
          logger.error('Error processing webhook event:', error);
        });
      }
    } else {
      // Single event (legacy format)
      logger.info('Processing single webhook event:', {
        eventType: webhookData.eventType,
        objectId: webhookData.objectId,
        objectType: webhookData.objectType,
        portalId: webhookData.portalId
      });
      
      processWebhookEvent(webhookData).catch(error => {
        logger.error('Error processing webhook:', error);
      });
    }

    // Respond immediately to HubSpot
    res.status(200).json({ status: 'received' });
  } catch (error) {
    logger.error('Webhook handler error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { handleWebhook };