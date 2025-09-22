# 🍎 LeedsLink Backend Hosting on Mac

## Overview

You can absolutely host your LeedsLink backend on your Mac! This is perfect for:
- **Development and testing**
- **Small production deployments**
- **Learning and experimentation**
- **Cost-effective hosting**

## Prerequisites

### Mac Requirements
- macOS 10.15+ (Catalina or later)
- Node.js 14+ installed
- npm installed
- Stable internet connection (for production)

### Network Requirements
- Your Mac and iOS device on the same network (for local testing)
- Port 3000 available
- Firewall configured to allow connections

## Quick Setup

### 1. Run the Setup Script

```bash
# Navigate to the backend-example directory
cd /Users/nmop/Documents/LeedsLink/LeedsLink/backend-example

# Run the Mac setup script
./setup-mac.sh
```

This will:
- ✅ Create a project directory in your home folder
- ✅ Install all dependencies
- ✅ Create startup scripts
- ✅ Detect your Mac's IP address
- ✅ Generate iOS configuration instructions

### 2. Start the Backend

```bash
# Navigate to the project directory
cd ~/LeedsLink-Backend

# Start the backend
./start-mac.sh
```

### 3. Update iOS App

1. Open `Config-Mac.swift` in Xcode
2. Update the IP address with your Mac's IP:
   ```swift
   static let macIP = "192.168.1.100" // Your actual Mac IP
   ```
3. Build and run your iOS app

## Detailed Setup

### Manual Installation

If you prefer to set up manually:

```bash
# Create project directory
mkdir ~/LeedsLink-Backend
cd ~/LeedsLink-Backend

# Copy the Mac server file
cp /path/to/mac-server.js .

# Create package.json
# (Copy from the setup script or create manually)

# Install dependencies
npm install

# Start the server
node mac-server.js
```

### Finding Your Mac's IP Address

```bash
# Method 1: Using ifconfig
ifconfig | grep "inet " | grep -v 127.0.0.1

# Method 2: Using system preferences
# System Preferences > Network > Wi-Fi > Advanced > TCP/IP

# Method 3: Using terminal
ipconfig getifaddr en0
```

## Network Configuration

### Local Network (Same Wi-Fi)

**For testing on the same network:**
- Mac IP: `192.168.1.100` (example)
- iOS app connects to: `http://192.168.1.100:3000/api`
- WebSocket: `ws://192.168.1.100:3000/ws`

### Internet Access (Production)

**For production use over the internet:**

1. **Port Forwarding** (Router configuration):
   - Forward external port 3000 to your Mac's IP:3000
   - Or use a different external port (e.g., 8080 → 3000)

2. **Dynamic DNS** (Optional):
   - Use services like No-IP, DuckDNS, or your router's built-in DDNS
   - Get a domain like `yourname.ddns.net`

3. **Firewall Configuration**:
   ```bash
   # Allow incoming connections on port 3000
   sudo pfctl -f /etc/pf.conf
   ```

## Testing the Setup

### 1. Test Backend

```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Test from another device on the network
curl http://YOUR_MAC_IP:3000/api/health
```

### 2. Test WebSocket

```javascript
// Test in browser console
const ws = new WebSocket('ws://YOUR_MAC_IP:3000/ws');
ws.onopen = () => console.log('✅ Connected to Mac');
ws.onmessage = (event) => console.log('📨 Message:', event.data);
```

### 3. Test iOS App

1. Build and run your iOS app
2. Go to TestRealtimeView
3. Check connection status
4. Test creating listings and sending messages

## Production Considerations

### Security

```bash
# Create a simple firewall rule
sudo pfctl -f /etc/pf.conf

# Or use macOS built-in firewall
# System Preferences > Security & Privacy > Firewall
```

### Process Management

```bash
# Install PM2 for process management
npm install -g pm2

# Start with PM2
pm2 start mac-server.js --name "leedslink-mac"

# Auto-start on boot
pm2 startup
pm2 save
```

### SSL/HTTPS (Optional)

For production, consider adding SSL:

```bash
# Install mkcert for local SSL
brew install mkcert
mkcert -install
mkcert localhost YOUR_MAC_IP

# Update server to use HTTPS
# (Modify mac-server.js to use SSL certificates)
```

## Troubleshooting

### Common Issues

**"Connection refused" errors:**
```bash
# Check if server is running
lsof -i :3000

# Check firewall
sudo pfctl -s rules
```

**iOS app can't connect:**
- Verify Mac and iOS device are on same network
- Check Mac's IP address hasn't changed
- Test API endpoint in browser first

**WebSocket connection fails:**
- Check if port 3000 is open
- Verify WebSocket URL is correct
- Test WebSocket in browser console

**Port already in use:**
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process
kill -9 PID

# Or use a different port
PORT=3001 node mac-server.js
```

### Debug Commands

```bash
# Check network interfaces
ifconfig

# Test port connectivity
nc -zv YOUR_MAC_IP 3000

# Check server logs
tail -f logs/combined.log

# Monitor network connections
netstat -an | grep 3000
```

## Performance Tips

### Optimize for Mac

```bash
# Increase file descriptor limits
ulimit -n 65536

# Optimize Node.js memory
node --max-old-space-size=4096 mac-server.js

# Use PM2 with clustering
pm2 start mac-server.js -i max
```

### Database Optimization

```bash
# SQLite optimizations (in mac-server.js)
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
PRAGMA cache_size=10000;
```

## Backup and Maintenance

### Database Backup

```bash
# Create backup script
cat > backup-db.sh << EOF
#!/bin/bash
DATE=\$(date +%Y%m%d_%H%M%S)
cp leedslink-mac.db "backups/leedslink-mac-\$DATE.db"
echo "✅ Database backed up: leedslink-mac-\$DATE.db"
EOF

chmod +x backup-db.sh
```

### Log Rotation

```bash
# Install logrotate
brew install logrotate

# Configure log rotation
# (Create logrotate configuration file)
```

## Cost Comparison

| Hosting Option | Cost | Pros | Cons |
|----------------|------|------|------|
| **Mac Hosting** | Free | Full control, No limits, Fast | Requires Mac always on, No redundancy |
| **Cloud Hosting** | $5-20/month | Reliable, Scalable, Professional | Monthly cost, Less control |
| **VPS** | $5-50/month | Full control, Scalable | Monthly cost, Management required |

## Success Checklist

- [ ] Mac backend running on port 3000
- [ ] iOS app connects to Mac IP
- [ ] Real-time features working
- [ ] Database persisting data
- [ ] WebSocket connections stable
- [ ] API endpoints responding
- [ ] Network accessible from iOS device
- [ ] Firewall configured (if needed)
- [ ] Process management set up (PM2)
- [ ] Backup strategy in place

## Next Steps

1. **Test locally** - Ensure everything works on your network
2. **Set up port forwarding** - For internet access
3. **Configure SSL** - For secure connections
4. **Set up monitoring** - Track performance and uptime
5. **Create backups** - Protect your data
6. **Scale as needed** - Move to cloud when ready

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify network connectivity
3. Test API endpoints manually
4. Check server logs
5. Ensure firewall settings are correct

Your Mac can absolutely serve as a production backend for LeedsLink! 🎉
