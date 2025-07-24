# Branch Protection Rules

This document outlines the branch protection rules that should be configured in GitHub for this repository.

## Branch Strategy

- **`develop`** - Default branch, receives feature branches
- **`staging`** - Pre-production environment, receives promotions from develop
- **`main`** - Production environment, receives promotions from staging

## Protection Rules

### For `main` (Production)
- ✅ Require pull request reviews before merging
  - Required approving reviews: 2
  - Dismiss stale pull request approvals when new commits are pushed
  - Require review from CODEOWNERS
- ✅ Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Required status checks:
    - `Test and Lint`
    - `Security Scan`
    - `Build Docker Image`
    - `Scan Container Image`
- ✅ Require conversation resolution before merging
- ✅ Require signed commits
- ✅ Include administrators
- ✅ Restrict who can push to matching branches
  - Allowed actors: `lucitra/devops-team`
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

### For `staging`
- ✅ Require pull request reviews before merging
  - Required approving reviews: 1
  - Dismiss stale pull request approvals when new commits are pushed
- ✅ Require status checks to pass before merging
  - Required status checks:
    - `Test and Lint`
    - `Security Scan`
    - `Build Docker Image`
- ✅ Require conversation resolution before merging
- ✅ Require signed commits
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

### For `develop`
- ✅ Require pull request reviews before merging
  - Required approving reviews: 1
- ✅ Require status checks to pass before merging
  - Required status checks:
    - `Test and Lint`
    - `Validate PR`
- ✅ Require conversation resolution before merging
- ❌ Do not allow force pushes
- ❌ Do not allow deletions

## Setting Up Protection Rules

To configure these rules:

1. Go to Settings → Branches in your GitHub repository
2. Add a branch protection rule for each branch
3. Configure the settings as outlined above
4. Save the changes

## Automated Enforcement

The CI/CD pipeline enforces additional checks:
- Conventional commit messages
- Branch naming conventions (type/description)
- Automated security scanning
- Container vulnerability scanning