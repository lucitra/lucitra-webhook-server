#!/bin/bash

# Example cURL commands to set up HubSpot webhooks
# Replace APP_ID and API_KEY with your actual values

APP_ID="YOUR_APP_ID"
API_KEY="YOUR_API_KEY"
WEBHOOK_URL="https://lucitra-webhook-server-dev-ygq5jwikta-uc.a.run.app/webhook"

# Update webhook settings
echo "Updating webhook settings..."
curl -X PUT \
  "https://api.hubapi.com/webhooks/v1/${APP_ID}/settings?hapikey=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "targetUrl": "'${WEBHOOK_URL}'",
    "throttling": {
      "maxConcurrentRequests": 10
    }
  }'

echo -e "\n\nCreating contact.creation subscription..."
curl -X POST \
  "https://api.hubapi.com/webhooks/v1/${APP_ID}/subscriptions?hapikey=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "subscriptionDetails": {
      "eventType": "contact.creation"
    },
    "enabled": true
  }'

echo -e "\n\nCreating deal.creation subscription..."
curl -X POST \
  "https://api.hubapi.com/webhooks/v1/${APP_ID}/subscriptions?hapikey=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "subscriptionDetails": {
      "eventType": "deal.creation"
    },
    "enabled": true
  }'