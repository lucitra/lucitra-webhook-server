# Lucitra Webhook Server

A webhook server for processing HubSpot events, deployed on Google Cloud Run.

## Quick Start

### Local Development
```bash
# Install dependencies
npm install

# Run locally
./scripts/local-dev.sh
```

### Deploy to Google Cloud Run
```bash
# Make sure you're logged into gcloud
gcloud auth login

# Deploy
./scripts/deploy.sh
```

## Environment Variables

- `PORT`: Server port (default: 8080)
- `NODE_ENV`: Environment (development/production)
- `LOG_LEVEL`: Logging level (debug/info/warn/error)
- `HUBSPOT_WEBHOOK_SECRET`: Secret for validating HubSpot webhooks

## Project Structure

```
lucitra-webhook-server/
├── src/
│   ├── index.js              # Main server
│   ├── handlers/             # Request handlers
│   ├── middleware/           # Express middleware
│   ├── services/             # Business logic
│   └── utils/                # Utilities
├── config/                   # Configuration files
├── scripts/                  # Deployment scripts
├── Dockerfile               # Container configuration
└── cloudbuild.yaml          # Cloud Build configuration
```

## API Endpoints

- `GET /`: Health check
- `POST /webhook`: HubSpot webhook endpoint

## Deployment

The server is configured to deploy to Google Cloud Run in the `lucitra-ai` project. The deployment process:

1. Builds a Docker container
2. Pushes to Google Container Registry
3. Deploys to Cloud Run with auto-scaling

## Monitoring

Logs are automatically sent to Google Cloud Logging when deployed. View logs:

```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=lucitra-webhook-server" --limit 50
```