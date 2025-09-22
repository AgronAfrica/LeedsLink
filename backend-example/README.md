# LeedsLink Backend Deployment Guide

## Prerequisites
- Namecheap hosting account with Node.js support
- SSH access to your server
- Domain name pointing to your hosting

## Step 1: Check Node.js Support
Most Namecheap shared hosting doesn't support Node.js. You'll need:
- **VPS Hosting** (recommended)
- **Dedicated Server**
- **Cloud Hosting** with Node.js support

## Step 2: Upload Files
Upload these files to your server:
- `server.js`
- `package.json`
- `README.md`

## Step 3: Install Dependencies
```bash
# SSH into your server
ssh your-username@your-domain.com

# Navigate to your project directory
cd /path/to/your/project

# Install Node.js dependencies
npm install
```

## Step 4: Start the Server
```bash
# For development
npm run dev

# For production (recommended)
npm start
```

## Step 5: Configure Process Manager (Production)
Install PM2 for process management:
```bash
npm install -g pm2
pm2 start server.js --name "leedslink-backend"
pm2 startup
pm2 save
```

## Step 6: Configure Reverse Proxy (if needed)
If using Apache/Nginx, configure reverse proxy:
```apache
# Apache .htaccess
RewriteEngine On
RewriteRule ^api/(.*)$ http://localhost:3000/api/$1 [P,L]
RewriteRule ^ws/(.*)$ ws://localhost:3000/ws/$1 [P,L]
```

## Step 7: Test the API
```bash
curl https://yourdomain.com/api/health
```

## Troubleshooting
- Check if port 3000 is open
- Verify Node.js version (14+ recommended)
- Check server logs for errors
- Ensure database permissions are correct
