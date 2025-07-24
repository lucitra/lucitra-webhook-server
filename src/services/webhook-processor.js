const { logger } = require('../utils/logger');

const processWebhookEvent = async (event) => {
  try {
    const { eventType, objectType, objectId, propertyName, propertyValue } = event;

    switch (eventType) {
      case 'contact.creation':
        await handleContactCreation(event);
        break;
      case 'contact.propertyChange':
        await handleContactPropertyChange(event);
        break;
      case 'contact.deletion':
        await handleContactDeletion(event);
        break;
      case 'deal.creation':
        await handleDealCreation(event);
        break;
      case 'deal.propertyChange':
        await handleDealPropertyChange(event);
        break;
      default:
        logger.info(`Unhandled event type: ${eventType}`);
    }
  } catch (error) {
    logger.error('Error processing webhook event:', error);
    throw error;
  }
};

const handleContactCreation = async (event) => {
  logger.info('Processing contact creation:', event.objectId);
  // Add your business logic here
};

const handleContactPropertyChange = async (event) => {
  logger.info('Processing contact property change:', {
    contactId: event.objectId,
    property: event.propertyName,
    value: event.propertyValue
  });
  // Add your business logic here
};

const handleDealCreation = async (event) => {
  logger.info('Processing deal creation:', event.objectId);
  // Add your business logic here
};

const handleDealPropertyChange = async (event) => {
  logger.info('Processing deal property change:', {
    dealId: event.objectId,
    property: event.propertyName,
    value: event.propertyValue
  });
  // Add your business logic here
};

const handleContactDeletion = async (event) => {
  // Note: HubSpot sends both regular deletions and privacy deletions 
  // through the same contact.deletion event
  logger.warn('Processing contact deletion:', {
    contactId: event.objectId,
    portalId: event.portalId
  });
  // TODO: Remove ALL contact data from your system
  // This could be a standard deletion OR a privacy deletion (GDPR)
  // Treat all deletions as if they were privacy deletions to be safe
};

module.exports = { processWebhookEvent };