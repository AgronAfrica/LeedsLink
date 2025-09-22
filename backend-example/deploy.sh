#!/bin/bash

# LeedsLink Backend Deployment Script
# Run this script on your Namecheap server

echo "🚀 Starting LeedsLink Backend Deployment..."

# Create logs directory
mkdir -p logs

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Install PM2 globally if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Stop existing PM2 process if running
echo "🛑 Stopping existing processes..."
pm2 stop leedslink-backend 2>/dev/null || true
pm2 delete leedslink-backend 2>/dev/null || true

# Start the application with PM2
echo "▶️ Starting application..."
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
pm2 save

# Setup PM2 startup script
pm2 startup

echo "✅ Deployment complete!"
echo "📊 Check status with: pm2 status"
echo "📋 View logs with: pm2 logs leedslink-backend"
echo "🌐 Test API: curl http://localhost:3000/api/health"
