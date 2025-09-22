# SSL Certificate Setup for LeedsLink Backend

## Option 1: Namecheap SSL Certificate (Recommended)

### 1. Purchase SSL Certificate
- Log into your Namecheap account
- Go to Domain List → Manage → SSL Certificates
- Purchase "PositiveSSL" or "EssentialSSL" (cheapest options)
- Follow the activation process

### 2. Install Certificate
- Download the certificate files from Namecheap
- Upload to your server's SSL directory (usually `/etc/ssl/` or `/etc/nginx/ssl/`)
- Update your web server configuration

### 3. Update Server Configuration
```javascript
// Update server.js to use HTTPS
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('/path/to/private.key'),
  cert: fs.readFileSync('/path/to/certificate.crt')
};

const server = https.createServer(options, app);
```

## Option 2: Let's Encrypt (Free)

### 1. Install Certbot
```bash
# For Ubuntu/Debian
sudo apt update
sudo apt install certbot python3-certbot-nginx

# For CentOS/RHEL
sudo yum install certbot python3-certbot-nginx
```

### 2. Get Certificate
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 3. Auto-renewal
```bash
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

## Option 3: Cloudflare (Free + Easy)

### 1. Add Domain to Cloudflare
- Sign up at cloudflare.com
- Add your domain
- Update nameservers at Namecheap

### 2. Enable SSL
- Go to SSL/TLS → Overview
- Set encryption mode to "Full" or "Full (strict)"
- Enable "Always Use HTTPS"

### 3. Update iOS App
```swift
// In Config.swift, use Cloudflare URLs
static let baseURL = "https://yourdomain.com/api"
static let webSocketURL = "wss://yourdomain.com/ws"
```

## Testing SSL

### 1. Test HTTPS
```bash
curl -I https://yourdomain.com/api/health
```

### 2. Test WebSocket
```javascript
// Test in browser console
const ws = new WebSocket('wss://yourdomain.com/ws');
ws.onopen = () => console.log('WebSocket connected');
ws.onmessage = (event) => console.log('Message:', event.data);
```

### 3. iOS App Test
- Build and run your iOS app
- Check that API calls work over HTTPS
- Verify WebSocket connections work over WSS

## Troubleshooting

### Common Issues:
1. **Mixed Content Errors**: Ensure all URLs use HTTPS/WSS
2. **Certificate Chain**: Make sure intermediate certificates are included
3. **Firewall**: Ensure ports 80 and 443 are open
4. **DNS**: Verify domain points to correct server

### Debug Commands:
```bash
# Check certificate
openssl s_client -connect yourdomain.com:443

# Test WebSocket
wscat -c wss://yourdomain.com/ws

# Check server logs
pm2 logs leedslink-backend
```
