# Lucitra Webhook Server

A webhook server for processing HubSpot events with multi-environment deployment pipeline.

[![Deploy Status](https://github.com/lucitra/lucitra-webhook-server/actions/workflows/terraform.yml/badge.svg)](https://github.com/lucitra/lucitra-webhook-server/actions)

## 🚀 Deployment Pipeline

```
local → develop → staging → production
```

- **Local**: Docker Compose for local development
- **Development**: Auto-deploy from `develop` branch
- **Staging**: Auto-deploy from `staging` branch with integration tests
- **Production**: Manual approval required, deploys from `main` branch

## Quick Start

### Local Development

```bash
# Clone and setup
git clone https://github.com/lucitra/lucitra-webhook-server.git
cd lucitra-webhook-server

# Copy environment variables
cp .env.example .env
# Edit .env with your values

# Run with Docker Compose
docker-compose up

# Or run directly
npm install
npm run dev
```

### Testing Locally with ngrok

```bash
# Start server with ngrok tunnel
docker-compose up

# Get public URL from ngrok dashboard
open http://localhost:4040
```

## 🏗️ Infrastructure as Code

This project uses Terraform for infrastructure management:

```bash
cd terraform

# Initialize Terraform
make init

# Deploy to development
make deploy-dev

# Deploy to staging
make apply ENV=staging

# Deploy to production (requires approval)
make apply ENV=prod
```

## 📝 Environment Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 8080 |
| `NODE_ENV` | Environment (development/staging/production) | development |
| `LOG_LEVEL` | Logging level (debug/info/warn/error) | info |
| `HUBSPOT_WEBHOOK_SECRET` | Secret for validating HubSpot webhooks | - |

### Environments

| Environment | Branch | Auto-Deploy | Scaling | URL |
|-------------|--------|-------------|---------|-----|
| Development | `develop` | ✅ | 1-10 instances | dev-webhook.lucitra.com |
| Staging | `staging` | ✅ | 1-50 instances | staging-webhook.lucitra.com |
| Production | `main` | ⚠️ (approval) | 2-100 instances | api.lucitra.com |

## 🛠️ Development Workflow

1. **Feature Development**
   ```bash
   git checkout develop
   git checkout -b feature/your-feature
   # Make changes
   git push origin feature/your-feature
   # Create PR to develop
   ```

2. **Testing in Staging**
   ```bash
   # After merge to develop
   git checkout staging
   git merge develop
   git push origin staging
   # Automatic deployment to staging
   ```

3. **Production Release**
   ```bash
   # After staging tests pass
   git checkout main
   git merge staging
   git push origin main
   # Requires manual approval in GitHub
   ```

## 📂 Project Structure

```
lucitra-webhook-server/
├── src/
│   ├── index.js              # Main server
│   ├── handlers/             # Request handlers
│   ├── middleware/           # Express middleware
│   ├── services/             # Business logic
│   └── utils/                # Utilities
├── terraform/                # Infrastructure as Code
│   ├── modules/              # Reusable modules
│   │   ├── gcp/             # Google Cloud modules
│   │   └── aws/             # AWS modules (future)
│   └── environments/         # Environment configs
├── .github/workflows/        # CI/CD pipelines
├── scripts/                  # Utility scripts
├── docker-compose.yml        # Local development
└── Dockerfile               # Container configuration
```

## 🔐 Security

- All webhooks are validated using HMAC signatures
- Service accounts use minimal permissions
- Cloud Armor enabled for DDoS protection
- All secrets managed through GitHub Secrets

## 📊 Monitoring

### View Logs

```bash
# Development logs
gcloud logging read "resource.labels.service_name=lucitra-webhook-server-dev" --limit 50

# Staging logs
gcloud logging read "resource.labels.service_name=lucitra-webhook-server-staging" --limit 50

# Production logs
gcloud logging read "resource.labels.service_name=lucitra-webhook-server" --limit 50
```

### Metrics

- Request latency
- Error rates
- Instance count
- Memory/CPU usage

Available in Google Cloud Console → Monitoring

## 🚨 Troubleshooting

### Common Issues

1. **Deployment fails with authentication error**
   - Ensure `GOOGLE_CREDENTIALS` secret is set in GitHub
   - Check service account permissions

2. **Webhook validation fails**
   - Verify `HUBSPOT_WEBHOOK_SECRET` matches HubSpot configuration
   - Check request signatures in logs

3. **Local development issues**
   - Run `docker-compose down -v` to reset
   - Check `.env` file exists with correct values

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch from `develop`
3. Commit your changes
4. Push to your fork
5. Create a Pull Request to `develop`

## 📄 License

MIT License - see LICENSE file for details