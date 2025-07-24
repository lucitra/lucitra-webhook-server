#!/bin/bash

# Script to set up Git branches and protection rules

set -e

echo "🌿 Setting up Git branches for deployment pipeline..."

# Create branches if they don't exist
create_branch() {
  local branch=$1
  if ! git show-ref --verify --quiet refs/heads/$branch; then
    echo "Creating branch: $branch"
    git checkout -b $branch
    git push -u origin $branch
  else
    echo "Branch $branch already exists"
  fi
}

# Return to main branch
git checkout main

# Create development branch
create_branch "develop"

# Create staging branch
create_branch "staging"

# Return to main
git checkout main

echo "
✅ Branches created successfully!

📋 Next steps:
1. Go to https://github.com/lucitra/lucitra-webhook-server/settings/branches
2. Add branch protection rules:

   For 'main' branch:
   - Require pull request reviews (2 approvals)
   - Require status checks to pass (staging deployment)
   - Require branches to be up to date
   - Include administrators
   
   For 'staging' branch:
   - Require pull request reviews (1 approval)
   - Require status checks to pass (terraform-check, local-test)
   - Require branches to be up to date
   
   For 'develop' branch:
   - Require status checks to pass (terraform-check, local-test)

3. Set up GitHub environments:
   - development (auto-deploy from develop)
   - staging (auto-deploy from staging)
   - production (requires approval, deploys from main)
"