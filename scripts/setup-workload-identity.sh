#!/bin/bash

# Script to set up Workload Identity Federation for GitHub Actions

set -e

PROJECT_ID="lucitra-ai"
SERVICE_ACCOUNT_NAME="github-actions-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
POOL_NAME="github-actions-pool"
PROVIDER_NAME="github-provider"
REPO="lucitra/lucitra-webhook-server"

echo "🔐 Setting up Workload Identity Federation..."

# Get project number
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
echo "📋 Project Number: ${PROJECT_NUMBER}"

# Create Workload Identity Pool
echo "🏊 Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "${POOL_NAME}" \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --description="Workload Identity Pool for GitHub Actions" || echo "Pool already exists"

# Create Workload Identity Provider
echo "🔗 Creating Workload Identity Provider..."
gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
  --location="global" \
  --workload-identity-pool="${POOL_NAME}" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com" || echo "Provider already exists"

# Get the full provider name
WORKLOAD_IDENTITY_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME}"
echo "📍 Workload Identity Provider: ${WORKLOAD_IDENTITY_PROVIDER}"

# Grant permissions to the existing service account
echo "🔑 Granting permissions to service account..."
roles=(
    "roles/run.admin"
    "roles/storage.admin"
    "roles/cloudbuild.builds.builder"
    "roles/serviceusage.serviceUsageConsumer"
    "roles/iam.serviceAccountUser"
)

for role in "${roles[@]}"; do
    echo "  - Adding ${role}..."
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="${role}" \
        --quiet || true
done

# Allow GitHub to impersonate the service account
echo "👤 Configuring service account impersonation..."
gcloud iam service-accounts add-iam-policy-binding \
  "${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/attribute.repository/${REPO}"

echo "
✅ Workload Identity Federation setup complete!

📋 Next steps:
1. Update .github/workflows/terraform.yml with these values:
   - workload_identity_provider: ${WORKLOAD_IDENTITY_PROVIDER}
   - service_account: ${SERVICE_ACCOUNT_EMAIL}

2. Remove GOOGLE_CREDENTIALS from GitHub Secrets (no longer needed)

3. Push changes to test the new authentication

Example workflow authentication step:
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: '${WORKLOAD_IDENTITY_PROVIDER}'
    service_account: '${SERVICE_ACCOUNT_EMAIL}'
"