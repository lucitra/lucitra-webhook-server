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
      case 'contact.privacyDeletion':
        await handleContactPrivacyDeletion(event);
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
  logger.info('Processing contact deletion:', {
    contactId: event.objectId,
    portalId: event.portalId
  });
  // TODO: Remove contact data from your system
  // This is a standard deletion (user deleted the contact)
};

const handleContactPrivacyDeletion = async (event) => {
  logger.warn('Processing contact PRIVACY deletion (GDPR/Legal):', {
    contactId: event.objectId,
    portalId: event.portalId
  });
  // TODO: IMPORTANT - Remove ALL contact data from your system
  // This is a legal/privacy deletion request (GDPR, etc.)
  // You MUST delete all data related to this contact
};

module.exports = { processWebhookEvent };