# 🚀 LeedsLink Backend Deployment Checklist

## ✅ Pre-Deployment

### 1. Server Requirements
- [ ] Node.js 14+ installed
- [ ] npm installed
- [ ] SSH access to server
- [ ] Domain pointing to server
- [ ] Ports 80, 443, and 3000 open

### 2. Files Ready
- [ ] `server.js` - Main server file
- [ ] `package.json` - Dependencies
- [ ] `ecosystem.config.js` - PM2 configuration
- [ ] `deploy.sh` - Deployment script
- [ ] `.htaccess` - Apache configuration (if using Apache)

## ✅ Step 1: Deploy Backend

### Upload Files
```bash
# Upload all files to your server
scp -r backend-example/* user@yourdomain.com:/path/to/project/
```

### Install and Start
```bash
# SSH into server
ssh user@yourdomain.com

# Navigate to project
cd /path/to/project/

# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### Verify Backend
```bash
# Check if server is running
pm2 status

# Test API endpoint
curl http://localhost:3000/api/health

# Check logs
pm2 logs leedslink-backend
```

## ✅ Step 2: Update iOS App

### Update Domain
1. Open `Config.swift` in Xcode
2. Replace `yourdomain.com` with your actual domain:
   ```swift
   static let baseURL = "https://yourdomain.com/api"
   static let webSocketURL = "wss://yourdomain.com/ws"
   ```

### Test Configuration
1. Build and run the app
2. Navigate to TestRealtimeView
3. Check connection status

## ✅ Step 3: Test Real-time Features

### Test API Connection
1. Open the app
2. Go to TestRealtimeView
3. Tap "Test API Connection"
4. Should see "✅ API connection successful!"

### Test Live Posting
1. Enter a test listing title
2. Tap "Create Test Listing"
3. Check server logs for new listing
4. Should see real-time update

### Test Live Messaging
1. Enter a test message
2. Tap "Send Test Message"
3. Check server logs for new message
4. Should see real-time update

### Test WebSocket
1. Check connection status (green dot = connected)
2. Send a message from another device/browser
3. Should see real-time updates

## ✅ Step 4: SSL Certificate

### Choose SSL Option
- [ ] **Namecheap SSL** (Paid, $5-10/year)
- [ ] **Let's Encrypt** (Free, requires setup)
- [ ] **Cloudflare** (Free, easiest)

### Test HTTPS
```bash
# Test API over HTTPS
curl -I https://yourdomain.com/api/health

# Test WebSocket over WSS
# Use browser console or wscat
```

### Update iOS App
- [ ] Verify HTTPS URLs in Config.swift
- [ ] Test app with HTTPS endpoints
- [ ] Verify WebSocket works over WSS

## ✅ Final Verification

### Backend Tests
- [ ] API responds to health check
- [ ] Can create listings via API
- [ ] Can send messages via API
- [ ] WebSocket accepts connections
- [ ] Real-time updates work

### iOS App Tests
- [ ] App connects to backend
- [ ] Can create listings from app
- [ ] Can send messages from app
- [ ] Real-time updates appear
- [ ] Works offline (local storage)
- [ ] Syncs when back online

### Production Checklist
- [ ] SSL certificate installed
- [ ] HTTPS/WSS working
- [ ] PM2 auto-restart enabled
- [ ] Logs being written
- [ ] Database persisting data
- [ ] Firewall configured
- [ ] Domain DNS correct

## 🆘 Troubleshooting

### Common Issues

**Backend won't start:**
```bash
# Check Node.js version
node --version

# Check dependencies
npm install

# Check logs
pm2 logs leedslink-backend
```

**iOS app can't connect:**
- Verify domain in Config.swift
- Check if server is running
- Test API endpoint in browser
- Check firewall settings

**WebSocket not working:**
- Verify WSS URL in Config.swift
- Check if port 443 is open
- Test WebSocket in browser console
- Check server WebSocket logs

**SSL issues:**
- Verify certificate is valid
- Check certificate chain
- Test with SSL checker tools
- Ensure all URLs use HTTPS/WSS

## 📞 Support

If you encounter issues:
1. Check server logs: `pm2 logs leedslink-backend`
2. Test API endpoints manually
3. Verify network connectivity
4. Check SSL certificate status
5. Review this checklist

## 🎉 Success!

Once all items are checked:
- Your LeedsLink app has live posting
- Real-time messaging works
- Data syncs between devices
- Works offline and online
- Secure HTTPS/WSS connections
- Production-ready backend
