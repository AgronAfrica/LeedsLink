#!/bin/bash

# LeedsLink Backend Setup Script for Mac
# Run this script on your Mac to set up the backend

echo "🍎 Setting up LeedsLink Backend on Mac..."

# Get Mac's IP address
MAC_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
echo "📱 Your Mac's IP address: $MAC_IP"

# Create project directory
PROJECT_DIR="$HOME/LeedsLink-Backend"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "📁 Project directory: $PROJECT_DIR"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first:"
    echo "   Visit: https://nodejs.org/"
    echo "   Or install via Homebrew: brew install node"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ npm version: $(npm --version)"

# Create package.json for Mac
cat > package.json << EOF
{
  "name": "leedslink-mac-backend",
  "version": "1.0.0",
  "description": "LeedsLink Backend running on Mac",
  "main": "mac-server.js",
  "scripts": {
    "start": "node mac-server.js",
    "dev": "nodemon mac-server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.14.2",
    "sqlite3": "^5.1.6",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  },
  "keywords": [
    "leedslink",
    "mac",
    "api",
    "websocket",
    "real-time",
    "messaging",
    "ios"
  ],
  "author": "LeedsLink Team",
  "license": "MIT"
}
EOF

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create logs directory
mkdir -p logs

# Create a simple start script
cat > start-mac.sh << EOF
#!/bin/bash
echo "🚀 Starting LeedsLink Backend on Mac..."
echo "📱 Your Mac's IP: $MAC_IP"
echo "🌐 Access URLs:"
echo "   - http://localhost:3000"
echo "   - http://$MAC_IP:3000"
echo "🔌 WebSocket: ws://$MAC_IP:3000/ws"
echo ""
node mac-server.js
EOF

chmod +x start-mac.sh

# Create a development script
cat > dev-mac.sh << EOF
#!/bin/bash
echo "🛠️ Starting LeedsLink Backend in development mode on Mac..."
echo "📱 Your Mac's IP: $MAC_IP"
echo "🌐 Access URLs:"
echo "   - http://localhost:3000"
echo "   - http://$MAC_IP:3000"
echo "🔌 WebSocket: ws://$MAC_IP:3000/ws"
echo ""
npx nodemon mac-server.js
EOF

chmod +x dev-mac.sh

# Create a test script
cat > test-mac.sh << EOF
#!/bin/bash
echo "🧪 Testing LeedsLink Backend on Mac..."
echo ""

# Test health endpoint
echo "🏥 Testing health endpoint..."
curl -s "http://localhost:3000/api/health" | python3 -m json.tool
echo ""

# Test listings endpoint
echo "📋 Testing listings endpoint..."
curl -s "http://localhost:3000/api/listings" | python3 -m json.tool
echo ""

echo "✅ Mac backend tests complete!"
EOF

chmod +x test-mac.sh

# Create iOS configuration helper
cat > ios-config-helper.txt << EOF
🍎 iOS App Configuration for Mac Backend

1. Update Config-Mac.swift with your Mac's IP:
   static let macIP = "$MAC_IP"

2. Or use localhost for testing on the same Mac:
   static let macIP = "localhost"

3. Build and run your iOS app

4. Test the connection using TestRealtimeView

📱 Your Mac's IP: $MAC_IP
🌐 API URL: http://$MAC_IP:3000/api
🔌 WebSocket: ws://$MAC_IP:3000/ws
EOF

echo ""
echo "✅ LeedsLink Backend setup complete on Mac!"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo "📱 Your Mac's IP: $MAC_IP"
echo ""
echo "🚀 To start the backend:"
echo "   cd $PROJECT_DIR"
echo "   ./start-mac.sh"
echo ""
echo "🛠️ For development (auto-restart):"
echo "   cd $PROJECT_DIR"
echo "   ./dev-mac.sh"
echo ""
echo "🧪 To test the backend:"
echo "   cd $PROJECT_DIR"
echo "   ./test-mac.sh"
echo ""
echo "📱 iOS App Configuration:"
echo "   See ios-config-helper.txt for details"
echo ""
echo "🌐 Access URLs:"
echo "   - http://localhost:3000"
echo "   - http://$MAC_IP:3000"
echo "   - WebSocket: ws://$MAC_IP:3000/ws"
echo ""
echo "🎉 Ready to run LeedsLink backend on your Mac!"
