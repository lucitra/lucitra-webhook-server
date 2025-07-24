# Setting up Workload Identity Federation for GitHub Actions

This is the secure, keyless way to authenticate GitHub Actions with Google Cloud.

## Steps:

### 1. Create Workload Identity Pool
```bash
gcloud iam workload-identity-pools create "github-actions-pool" \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --description="Workload Identity Pool for GitHub Actions"
```

### 2. Create Workload Identity Provider
```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### 3. Get the Workload Identity Provider name
```bash
gcloud iam workload-identity-pools providers describe "github-provider" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --format="value(name)"
```

### 4. Create Service Account (if not already created)
```bash
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account"
```

### 5. Grant permissions to the service account
```bash
PROJECT_ID="lucitra-ai"
SERVICE_ACCOUNT_EMAIL="github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com"

# Grant necessary roles
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/cloudbuild.builds.builder"
```

### 6. Allow GitHub to impersonate the service account
```bash
gcloud iam service-accounts add-iam-policy-binding \
  "github-actions-sa@lucitra-ai.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/lucitra/lucitra-webhook-server"
```

Replace PROJECT_NUMBER with your actual project number (find it in the project dashboard).

### 7. Update GitHub Workflow

In the workflow file, replace the auth step with:

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider'
    service_account: 'github-actions-sa@lucitra-ai.iam.gserviceaccount.com'
```

No secrets needed!