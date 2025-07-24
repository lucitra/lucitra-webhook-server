# Development Workflow Guide

## Overview

This repository follows a structured Git workflow optimized for containerized applications with clear promotion paths from development to production.

## Branch Structure

```
main (production)
  ↑
staging (pre-production)
  ↑
develop (default branch)
  ↑
feature/* | fix/* | chore/*
```

### Branch Descriptions

- **`develop`** - Default branch where all development happens
- **`staging`** - Pre-production environment for final testing
- **`main`** - Production environment (protected)
- **`feature/*`** - New features
- **`fix/*`** - Bug fixes
- **`hotfix/*`** - Emergency production fixes
- **`chore/*`** - Maintenance tasks

## Development Workflow

### 1. Starting New Work

```bash
# Ensure you're up to date
git checkout develop
git pull origin develop

# Create a new feature branch
git checkout -b feature/your-feature-name

# Or for a bug fix
git checkout -b fix/issue-description
```

### 2. Branch Naming Convention

Use the format: `type/description`

Examples:
- `feature/add-webhook-validation`
- `fix/memory-leak-in-processor`
- `chore/update-dependencies`
- `docs/api-documentation`

### 3. Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer(s)]
```

Examples:
- `feat(webhook): add payload validation`
- `fix(auth): resolve token expiration issue`
- `docs(api): update webhook endpoint documentation`
- `chore(deps): update express to v4.18.0`

### 4. Creating a Pull Request

1. Push your branch:
   ```bash
   git push -u origin feature/your-feature-name
   ```

2. Create PR via GitHub UI or CLI:
   ```bash
   gh pr create --base develop --title "feat: your feature" --body "Description"
   ```

3. Fill out the PR template completely

4. Ensure all checks pass

### 5. Code Review Process

- All PRs require at least 1 approval
- Address all feedback comments
- Keep PRs focused and small
- Update branch with develop if needed:
  ```bash
  git checkout feature/your-feature
  git rebase develop
  ```

## Deployment Pipeline

### Automatic Deployments

- **develop → Development Environment**: Automatic on merge
- **staging → Staging Environment**: Automatic on merge
- **main → Production Environment**: Automatic with manual approval

### Promotion Process

To promote changes between environments:

1. **Develop to Staging**:
   ```bash
   # Using GitHub UI
   # Go to Actions → Promote Changes → Run workflow
   # Select: source=develop, target=staging
   ```

2. **Staging to Production**:
   ```bash
   # Using GitHub UI
   # Go to Actions → Promote Changes → Run workflow
   # Select: source=staging, target=main
   ```

### Manual Promotion (Alternative)

```bash
# Promote develop to staging
gh workflow run promote.yml -f source_branch=develop -f target_branch=staging -f pr_title="Release to staging"

# Promote staging to production
gh workflow run promote.yml -f source_branch=staging -f target_branch=main -f pr_title="Release to production"
```

## CI/CD Pipeline

### Pipeline Stages

1. **Test & Lint** - Runs on all branches
2. **Security Scan** - Vulnerability scanning
3. **Build Docker Image** - Multi-platform build
4. **Container Scan** - Image vulnerability scan
5. **Deploy** - Environment-specific deployment

### Quality Gates

All PRs must pass:
- ✅ Unit tests
- ✅ Linting
- ✅ Security scans
- ✅ Build validation
- ✅ PR validation (naming, commits)

## Container Best Practices

### Docker Build

The pipeline automatically:
- Builds multi-platform images (amd64, arm64)
- Tags images with branch and commit SHA
- Pushes to GitHub Container Registry
- Scans for vulnerabilities

### Image Tags

- `develop` - Latest development build
- `staging` - Latest staging build
- `main` - Latest production build
- `develop-abc123` - Specific commit build
- `v1.2.3` - Semantic version (production releases)

## Emergency Procedures

### Hotfix Process

For critical production issues:

1. Create hotfix from main:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/critical-issue
   ```

2. Make minimal changes

3. Create PR directly to main

4. After merge, backport to develop and staging:
   ```bash
   git checkout develop
   git cherry-pick <hotfix-commit>
   git push origin develop
   ```

### Rollback Process

To rollback a deployment:

1. Identify the last known good image tag
2. Run deployment with specific tag:
   ```bash
   ./scripts/deploy.sh prod ghcr.io/lucitra/webhook-server:last-good-tag
   ```

## Monitoring & Alerts

- Check GitHub Actions for build status
- Monitor deployment environments
- Review security scan results in Security tab
- Track dependency updates via Dependabot

## Common Commands

```bash
# Check current branch
git branch --show-current

# Update your fork
git fetch upstream
git checkout develop
git merge upstream/develop

# Clean up local branches
git branch --merged | grep -v "\*\|main\|develop\|staging" | xargs -n 1 git branch -d

# View deployment history
gh run list --workflow=ci-cd.yml

# Check security vulnerabilities
gh secret scan
```

## Getting Help

- Review existing PRs for examples
- Check Actions tab for build logs
- Consult team leads for architectural decisions
- Open an issue for workflow improvements