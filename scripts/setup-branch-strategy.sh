#!/bin/bash

# Script to set up the branch strategy for the repository
# This sets develop as the default branch and ensures proper branch structure

set -e

echo "🚀 Setting up branch strategy..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Function to check if branch exists locally
branch_exists_local() {
    git rev-parse --verify "$1" >/dev/null 2>&1
}

# Function to check if branch exists on remote
branch_exists_remote() {
    git ls-remote --heads origin "$1" | grep -q "$1"
}

# Ensure we have the latest remote information
echo "📡 Fetching latest from remote..."
git fetch origin

# Create main branch if it doesn't exist
if ! branch_exists_local "main"; then
    echo -e "${YELLOW}Creating main branch...${NC}"
    if branch_exists_remote "main"; then
        git checkout -b main origin/main
    else
        # Create main from current branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        git checkout -b main
        git push -u origin main
        git checkout "$current_branch"
    fi
else
    echo -e "${GREEN}✅ main branch already exists${NC}"
fi

# Create staging branch if it doesn't exist
if ! branch_exists_local "staging"; then
    echo -e "${YELLOW}Creating staging branch...${NC}"
    if branch_exists_remote "staging"; then
        git checkout -b staging origin/staging
    else
        # Create staging from main
        git checkout main
        git checkout -b staging
        git push -u origin staging
    fi
else
    echo -e "${GREEN}✅ staging branch already exists${NC}"
fi

# Create develop branch if it doesn't exist
if ! branch_exists_local "develop"; then
    echo -e "${YELLOW}Creating develop branch...${NC}"
    if branch_exists_remote "develop"; then
        git checkout -b develop origin/develop
    else
        # Create develop from staging
        git checkout staging
        git checkout -b develop
        git push -u origin develop
    fi
else
    echo -e "${GREEN}✅ develop branch already exists${NC}"
fi

# Switch to develop branch
echo "📌 Switching to develop branch..."
git checkout develop

# Update the default branch on GitHub (requires GitHub CLI)
if command -v gh &> /dev/null; then
    echo "🔧 Setting develop as the default branch on GitHub..."
    gh repo edit --default-branch develop
    echo -e "${GREEN}✅ Default branch updated to develop${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub CLI not found. Please manually set 'develop' as the default branch in GitHub settings.${NC}"
    echo "   Go to: Settings → General → Default branch → Change to 'develop'"
fi

echo ""
echo -e "${GREEN}✅ Branch strategy setup complete!${NC}"
echo ""
echo "📋 Branch Structure:"
echo "   • develop (default) - Active development"
echo "   • staging - Pre-production testing"
echo "   • main - Production releases"
echo ""
echo "📌 Next Steps:"
echo "   1. Configure branch protection rules (see .github/BRANCH_PROTECTION.md)"
echo "   2. Update your team on the new workflow"
echo "   3. Start creating feature branches from develop"
echo ""
echo "🔄 Promotion Flow:"
echo "   feature/* → develop → staging → main"
echo ""