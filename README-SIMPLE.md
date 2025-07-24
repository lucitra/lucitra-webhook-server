# Simple Solo Developer Workflow

## Quick Deploy

### Deploy to Dev
```bash
git push origin develop
```
→ Automatically deploys to `lucitra-webhook-server-dev`

### Deploy to Production
```bash
git push origin main
```
→ Automatically deploys to `lucitra-webhook-server-prod`

## That's it!

No PRs required, no approvals needed. Just push and deploy.

### Quick Commands

```bash
# Work on develop branch
git checkout develop
git add .
git commit -m "your changes"
git push

# When ready for production
git checkout main
git merge develop
git push
```

### URLs
- Dev: Check GitHub Actions output
- Prod: Check GitHub Actions output

### If you need staging later
Just push to a `staging` branch - the workflow will handle it.