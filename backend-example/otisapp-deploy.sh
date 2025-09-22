#!/bin/bash

# LeedsLink Backend Deployment Script for otisapp.com
# Run this script on your otisapp.com server

echo "🚀 Starting LeedsLink Backend Deployment on otisapp.com..."

# Create logs directory
mkdir -p logs

# Rename package.json for otisapp.com
if [ -f "otisapp-package.json" ]; then
    cp otisapp-package.json package.json
    echo "📦 Using otisapp.com specific package.json"
fi

# Rename server.js for otisapp.com
if [ -f "otisapp-server.js" ]; then
    cp otisapp-server.js server.js
    echo "📦 Using otisapp.com specific server.js"
fi

# Install dependencies
echo "📦 Installing dependencies for otisapp.com..."
npm install

# Install PM2 globally if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Stop existing PM2 process if running
echo "🛑 Stopping existing LeedsLink processes..."
pm2 stop leedslink-otisapp 2>/dev/null || true
pm2 delete leedslink-otisapp 2>/dev/null || true

# Update ecosystem.config.js for otisapp.com
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'leedslink-otisapp',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Start the application with PM2
echo "▶️ Starting LeedsLink backend on otisapp.com..."
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
pm2 save

# Setup PM2 startup script
pm2 startup

echo "✅ LeedsLink Backend deployment complete on otisapp.com!"
echo ""
echo "📊 Check status with: pm2 status"
echo "📋 View logs with: pm2 logs leedslink-otisapp"
echo "🌐 Test API: curl https://otisapp.com/api/health"
echo "🔌 Test WebSocket: wscat -c wss://otisapp.com/ws"
echo ""
echo "🎉 Your LeedsLink backend is now running on otisapp.com!"
echo "📱 Update your iOS app to use: https://otisapp.com/api"
