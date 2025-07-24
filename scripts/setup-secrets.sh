#!/bin/bash

# Script to set up secrets in Google Secret Manager

echo "🔐 Setting up secrets in Google Secret Manager..."

# Enable Secret Manager API
gcloud services enable secretmanager.googleapis.com

# Create secret for HubSpot webhook
echo -n "Enter your HubSpot Webhook Secret: "
read -s WEBHOOK_SECRET
echo

# Create the secret
echo -n "$WEBHOOK_SECRET" | gcloud secrets create hubspot-webhook-secret \
    --data-file=- \
    --replication-policy="automatic"

# Grant service account access
gcloud secrets add-iam-policy-binding hubspot-webhook-secret \
    --member="serviceAccount:github-actions-sa@lucitra-ai.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

echo "✅ Secret created successfully!"
echo ""
echo "To use in your code:"
echo "1. Install @google-cloud/secret-manager"
echo "2. Access the secret in your app"
echo ""
echo "Or set it as GitHub secret:"
echo "Go to: https://github.com/lucitra/lucitra-webhook-server/settings/secrets/actions/new"
echo "Name: HUBSPOT_WEBHOOK_SECRET"
echo "Value: $WEBHOOK_SECRET"