#!/usr/bin/env node

// Script to configure HubSpot webhooks via API
// Usage: node setup-hubspot-webhooks.js <APP_ID> <DEVELOPER_API_KEY>

const https = require('https');

const APP_ID = process.argv[2];
const DEVELOPER_API_KEY = process.argv[3];
const WEBHOOK_URL = 'https://lucitra-webhook-server-dev-ygq5jwikta-uc.a.run.app/webhook';

if (!APP_ID || !DEVELOPER_API_KEY) {
  console.error('Usage: node setup-hubspot-webhooks.js <APP_ID> <DEVELOPER_API_KEY>');
  console.error('\nGet these from:');
  console.error('1. APP_ID: Your app ID from HubSpot developer account');
  console.error('2. DEVELOPER_API_KEY: Your developer API key (hapikey)');
  process.exit(1);
}

// Webhook subscriptions to create
const subscriptions = [
  {
    eventType: 'contact.creation',
    propertyName: null
  },
  {
    eventType: 'contact.propertyChange',
    propertyName: 'email'
  },
  {
    eventType: 'contact.propertyChange', 
    propertyName: 'lifecyclestage'
  },
  {
    eventType: 'deal.creation',
    propertyName: null
  },
  {
    eventType: 'deal.propertyChange',
    propertyName: 'dealstage'
  },
  {
    eventType: 'deal.propertyChange',
    propertyName: 'amount'
  }
];

// Update webhook settings
function updateWebhookSettings() {
  const data = JSON.stringify({
    targetUrl: WEBHOOK_URL,
    throttling: {
      maxConcurrentRequests: 10
    }
  });

  const options = {
    hostname: 'api.hubapi.com',
    port: 443,
    path: `/webhooks/v1/${APP_ID}/settings?hapikey=${DEVELOPER_API_KEY}`,
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log('✅ Webhook settings updated successfully');
          console.log(`   Target URL: ${WEBHOOK_URL}`);
          resolve();
        } else {
          console.error('❌ Failed to update webhook settings:', body);
          reject(new Error(body));
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

// Create a subscription
function createSubscription(subscription) {
  const data = JSON.stringify({
    subscriptionDetails: subscription,
    enabled: true
  });

  const options = {
    hostname: 'api.hubapi.com',
    port: 443,
    path: `/webhooks/v1/${APP_ID}/subscriptions?hapikey=${DEVELOPER_API_KEY}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode === 201) {
          const propertyInfo = subscription.propertyName ? ` (${subscription.propertyName})` : '';
          console.log(`✅ Created subscription: ${subscription.eventType}${propertyInfo}`);
          resolve();
        } else {
          console.error(`❌ Failed to create subscription ${subscription.eventType}:`, body);
          // Continue with other subscriptions even if one fails
          resolve();
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

// Main setup function
async function setupWebhooks() {
  console.log('🚀 Setting up HubSpot webhooks...\n');
  
  try {
    // First update the webhook settings
    await updateWebhookSettings();
    console.log('');
    
    // Then create all subscriptions
    console.log('📋 Creating webhook subscriptions...');
    for (const subscription of subscriptions) {
      await createSubscription(subscription);
    }
    
    console.log('\n✨ Webhook setup complete!');
    console.log('\n⚠️  IMPORTANT: Copy the webhook secret from your HubSpot app settings');
    console.log('    and add it to GitHub Secrets as HUBSPOT_WEBHOOK_SECRET');
    
  } catch (error) {
    console.error('\n❌ Setup failed:', error.message);
    process.exit(1);
  }
}

// Run the setup
setupWebhooks();