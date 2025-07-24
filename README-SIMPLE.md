# Simple Solo Developer Workflow

## 🚀 Environments

- **Local**: Run on your machine with `npm run dev` or `docker-compose up`
- **Dev**: Push to `develop` branch → `lucitra-webhook-server-dev`
- **Staging**: Push to `staging` branch → `lucitra-webhook-server-staging`
- **Production**: Push to `main` branch → `lucitra-webhook-server-prod`

## Quick Deploy Commands

### Deploy to Dev
```bash
git push origin develop
```

### Deploy to Staging
```bash
git checkout staging
git merge develop
git push origin staging
```

### Deploy to Production
```bash
git checkout main
git merge staging
git push origin main
```

## Typical Workflow

```bash
# 1. Work locally
git checkout develop
npm run dev  # or docker-compose up

# 2. Push to dev when ready
git add .
git commit -m "your changes"
git push origin develop

# 3. Test in staging
git checkout staging
git merge develop
git push origin staging

# 4. Deploy to production
git checkout main
git merge staging
git push origin main
```

## Service URLs
Check GitHub Actions output after each deployment for the URL.

No PRs required, no approvals needed. Just push and deploy!