#!/bin/bash

# Local development script

set -e

echo "🚀 Starting local development environment..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install Node.js first."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOL
PORT=8080
NODE_ENV=development
LOG_LEVEL=debug
HUBSPOT_WEBHOOK_SECRET=your-webhook-secret-here
EOL
    echo "⚠️  Please update .env with your actual webhook secret"
fi

# Start the development server
echo "🔧 Starting development server..."
npm run dev