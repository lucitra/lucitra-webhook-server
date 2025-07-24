#!/bin/bash

# Script to set up Google Cloud authentication

set -e

PROJECT_ID="lucitra-ai"
SERVICE_ACCOUNT_NAME="github-actions-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🔐 Setting up Google Cloud Service Account for GitHub Actions..."

# Check if gcloud is logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ Please login to gcloud first:"
    echo "   gcloud auth login"
    exit 1
fi

# Set project
echo "📋 Setting project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable storage-api.googleapis.com

# Create service account
echo "👤 Creating service account..."
if ! gcloud iam service-accounts describe ${SERVICE_ACCOUNT_EMAIL} &> /dev/null; then
    gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
        --display-name="GitHub Actions Service Account" \
        --description="Service account for GitHub Actions CI/CD"
else
    echo "Service account already exists"
fi

# Grant necessary roles
echo "🔑 Granting roles to service account..."
roles=(
    "roles/run.admin"
    "roles/storage.admin"
    "roles/cloudbuild.builds.builder"
    "roles/serviceusage.serviceUsageConsumer"
    "roles/iam.serviceAccountUser"
    "roles/resourcemanager.projectIamAdmin"
)

for role in "${roles[@]}"; do
    echo "  - Adding ${role}..."
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="${role}" \
        --quiet
done

# Create and download key
KEY_FILE="github-actions-sa-key.json"
echo "📥 Creating service account key..."
gcloud iam service-accounts keys create ${KEY_FILE} \
    --iam-account=${SERVICE_ACCOUNT_EMAIL}

echo "
✅ Service account created successfully!

📋 Next steps:
1. Copy the contents of ${KEY_FILE}:
   cat ${KEY_FILE}

2. Go to: https://github.com/lucitra/lucitra-webhook-server/settings/secrets/actions/new

3. Create a new secret:
   - Name: GOOGLE_CREDENTIALS
   - Value: Paste the entire JSON content

4. Delete the local key file for security:
   rm ${KEY_FILE}

⚠️  IMPORTANT: Never commit the service account key to git!
"