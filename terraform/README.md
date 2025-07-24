# Lucitra Terraform Infrastructure

This directory contains Terraform configurations for deploying the Lucitra webhook server across multiple cloud providers.

## Quick Start

### Prerequisites

1. Install Terraform (>= 1.5.0)
2. Configure cloud credentials:
   - For GCP: `gcloud auth application-default login`
   - For AWS: Configure AWS CLI or set environment variables

### Initial Setup

1. Create GCS bucket for Terraform state:
```bash
gsutil mb gs://lucitra-terraform-state
gsutil versioning set on gs://lucitra-terraform-state
```

2. Initialize Terraform:
```bash
cd terraform
make init
```

### Deployment

Deploy to development:
```bash
make deploy-dev
```

Deploy to production:
```bash
make deploy-prod
```

## Architecture

### Multi-Cloud Support
- **GCP**: Cloud Run (primary)
- **AWS**: ECS Fargate (future)

### Environments
- `dev`: Development environment with minimal resources
- `staging`: Staging environment (future)
- `prod`: Production environment with auto-scaling

## Directory Structure

```
terraform/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Global variables
├── outputs.tf             # Output definitions
├── Makefile               # Convenience commands
├── modules/               # Reusable modules
│   ├── gcp/              # GCP-specific modules
│   │   └── cloud-run/    # Cloud Run deployment
│   └── aws/              # AWS-specific modules
│       └── ecs/          # ECS deployment
└── environments/         # Environment-specific configs
    ├── dev/             # Development vars
    └── prod/            # Production vars
```

## Key Features

### GCP Cloud Run Module
- Auto-scaling (1-100 instances)
- Managed SSL certificates
- Cloud Armor DDoS protection
- Service account with minimal permissions
- Integration with Cloud Logging

### AWS ECS Module (Future)
- Fargate serverless containers
- Application Load Balancer
- Auto-scaling based on CPU
- VPC with public subnets

## Commands

```bash
# Format code
make fmt

# Validate configuration
make validate

# Plan changes
make plan ENV=dev

# Apply changes
make apply ENV=prod

# Destroy infrastructure
make destroy ENV=dev

# Show outputs
make output
```

## Switching Cloud Providers

To deploy to AWS instead of GCP:

1. Update the environment file:
```hcl
cloud_provider = "aws"
aws_region     = "us-east-1"
```

2. Deploy:
```bash
make apply ENV=dev
```

## Security Considerations

1. **State Management**: Terraform state is stored in GCS with versioning
2. **Service Accounts**: Minimal permissions following least privilege
3. **Network Security**: Cloud Armor on GCP, Security Groups on AWS
4. **Secrets**: Use environment variables, never commit secrets

## CI/CD Integration

GitHub Actions workflow automatically:
- Validates Terraform on PRs
- Deploys to dev on push to `develop`
- Deploys to prod on push to `main`

Required GitHub Secrets:
- `GOOGLE_CREDENTIALS`: Service account JSON for GCP
- `AWS_ACCESS_KEY_ID`: AWS access key (future)
- `AWS_SECRET_ACCESS_KEY`: AWS secret key (future)