const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { validateWebhook } = require('./middleware/validation');
const { handleWebhook } = require('./handlers/webhook');
const { logger } = require('./utils/logger');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'healthy', service: 'lucitra-webhook-server' });
});

// Main webhook endpoint
app.post('/webhook', validateWebhook, handleWebhook);

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  logger.info(`Webhook server listening on port ${PORT}`);
});