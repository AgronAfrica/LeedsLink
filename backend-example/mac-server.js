const express = require('express');
const WebSocket = require('ws');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');
const os = require('os');

const app = express();
const server = require('http').createServer(app);
const wss = new WebSocket.Server({ server });

// Get Mac's local IP address
function getLocalIPAddress() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const interface of interfaces[name]) {
            if (interface.family === 'IPv4' && !interface.internal) {
                return interface.address;
            }
        }
    }
    return 'localhost';
}

const LOCAL_IP = getLocalIPAddress();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
    origin: [
        'http://localhost:3000',
        'http://localhost:8080',
        `http://${LOCAL_IP}:3000`,
        `http://${LOCAL_IP}:8080`,
        'capacitor://localhost',
        'ionic://localhost',
        'http://localhost',
        'https://localhost'
    ],
    credentials: true
}));
app.use(express.json());
app.use(express.static('public'));

// Database setup for Mac
const db = new sqlite3.Database(path.join(__dirname, 'leedslink-mac.db'));

console.log(`🍎 LeedsLink Backend starting on Mac...`);
console.log(`📱 Local IP: ${LOCAL_IP}`);
console.log(`🌐 Access URLs:`);
console.log(`   - http://localhost:${PORT}`);
console.log(`   - http://${LOCAL_IP}:${PORT}`);
console.log(`   - WebSocket: ws://${LOCAL_IP}:${PORT}/ws`);

// Initialize database tables
db.serialize(() => {
    // Users table
    db.run(`CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        businessName TEXT,
        role TEXT NOT NULL,
        address TEXT,
        phoneNumber TEXT,
        postcode TEXT,
        description TEXT,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    // Listings table
    db.run(`CREATE TABLE IF NOT EXISTS listings (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        location TEXT,
        images TEXT, -- JSON array of image URLs
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (userId) REFERENCES users (id)
    )`);
    
    // Conversations table
    db.run(`CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY,
        listingId TEXT NOT NULL,
        participants TEXT NOT NULL, -- JSON array of user IDs
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        lastMessage TEXT,
        lastMessageAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (listingId) REFERENCES listings (id)
    )`);
    
    // Messages table
    db.run(`CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        readBy TEXT, -- JSON array of user IDs who read the message
        FOREIGN KEY (conversationId) REFERENCES conversations (id),
        FOREIGN KEY (senderId) REFERENCES users (id)
    )`);
    
    // Ratings table
    db.run(`CREATE TABLE IF NOT EXISTS ratings (
        id TEXT PRIMARY KEY,
        fromUserId TEXT NOT NULL,
        toUserId TEXT NOT NULL,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        review TEXT,
        category TEXT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (fromUserId) REFERENCES users (id),
        FOREIGN KEY (toUserId) REFERENCES users (id)
    )`);
});

// WebSocket connection handling
wss.on('connection', (ws) => {
    console.log('📱 New WebSocket connection to Mac backend');
    
    // Send welcome message with Mac info
    ws.send(JSON.stringify({
        type: 'connection',
        data: { 
            message: 'Connected to LeedsLink on Mac', 
            timestamp: new Date().toISOString(),
            server: 'Mac',
            ip: LOCAL_IP,
            port: PORT
        }
    }));
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('📨 Received on Mac:', data);
            
            // Broadcast to all connected clients
            wss.clients.forEach(client => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(data));
                }
            });
        } catch (error) {
            console.error('❌ Error parsing WebSocket message:', error);
        }
    });
    
    ws.on('close', () => {
        console.log('🔌 WebSocket connection closed on Mac');
    });
    
    ws.on('error', (error) => {
        console.error('❌ WebSocket error on Mac:', error);
    });
});

// Helper function to broadcast to all WebSocket clients
function broadcastToClients(type, data) {
    const message = JSON.stringify({ 
        type, 
        data: { ...data, server: 'Mac', ip: LOCAL_IP },
        timestamp: new Date().toISOString()
    });
    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });
}

// API Routes

// Get all listings
app.get('/api/listings', (req, res) => {
    db.all('SELECT * FROM listings ORDER BY createdAt DESC', (err, rows) => {
        if (err) {
            console.error('❌ Error fetching listings:', err);
            res.status(500).json({ error: err.message });
            return;
        }
        console.log(`📋 Fetched ${rows.length} listings from Mac`);
        res.json(rows);
    });
});

// Create new listing
app.post('/api/listings', (req, res) => {
    const { userId, title, description, category, price, location, images } = req.body;
    const id = require('crypto').randomUUID();
    
    console.log('📝 Creating new listing on Mac:', { id, title, userId });
    
    db.run(
        'INSERT INTO listings (id, userId, title, description, category, price, location, images) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [id, userId, title, description, category, price, location, JSON.stringify(images || [])],
        function(err) {
            if (err) {
                console.error('❌ Error creating listing:', err);
                res.status(500).json({ error: err.message });
                return;
            }
            
            console.log('✅ Listing created successfully on Mac:', id);
            
            // Broadcast new listing to all connected clients
            broadcastToClients('new_listing', {
                id,
                userId,
                title,
                description,
                category,
                price,
                location,
                images: images || [],
                createdAt: new Date().toISOString()
            });
            
            res.json({ id, message: 'Listing created successfully on Mac' });
        }
    );
});

// Get messages for a conversation
app.get('/api/messages/:conversationId', (req, res) => {
    const { conversationId } = req.params;
    
    db.all(
        'SELECT * FROM messages WHERE conversationId = ? ORDER BY timestamp ASC',
        [conversationId],
        (err, rows) => {
            if (err) {
                console.error('❌ Error fetching messages:', err);
                res.status(500).json({ error: err.message });
                return;
            }
            console.log(`💬 Fetched ${rows.length} messages for conversation ${conversationId} from Mac`);
            res.json(rows);
        }
    );
});

// Send a message
app.post('/api/messages', (req, res) => {
    const { conversationId, senderId, text } = req.body;
    const id = require('crypto').randomUUID();
    
    console.log('💬 Sending message on Mac:', { id, conversationId, senderId, text });
    
    db.run(
        'INSERT INTO messages (id, conversationId, senderId, text) VALUES (?, ?, ?, ?)',
        [id, conversationId, senderId, text],
        function(err) {
            if (err) {
                console.error('❌ Error sending message:', err);
                res.status(500).json({ error: err.message });
                return;
            }
            
            // Update conversation's last message
            db.run(
                'UPDATE conversations SET lastMessage = ?, lastMessageAt = CURRENT_TIMESTAMP WHERE id = ?',
                [text, conversationId]
            );
            
            console.log('✅ Message sent successfully on Mac:', id);
            
            // Broadcast new message to all connected clients
            broadcastToClients('new_message', {
                id,
                conversationId,
                senderId,
                text,
                timestamp: new Date().toISOString()
            });
            
            res.json({ id, message: 'Message sent successfully on Mac' });
        }
    );
});

// Create or get conversation
app.post('/api/conversations', (req, res) => {
    const { listingId, participants } = req.body;
    
    console.log('💬 Creating/getting conversation on Mac:', { listingId, participants });
    
    // Check if conversation already exists
    db.get(
        'SELECT * FROM conversations WHERE listingId = ? AND participants = ?',
        [listingId, JSON.stringify(participants.sort())],
        (err, row) => {
            if (err) {
                console.error('❌ Error checking conversation:', err);
                res.status(500).json({ error: err.message });
                return;
            }
            
            if (row) {
                console.log('✅ Conversation already exists on Mac:', row.id);
                res.json({ id: row.id, message: 'Conversation already exists on Mac' });
            } else {
                // Create new conversation
                const id = require('crypto').randomUUID();
                db.run(
                    'INSERT INTO conversations (id, listingId, participants) VALUES (?, ?, ?)',
                    [id, listingId, JSON.stringify(participants)],
                    function(err) {
                        if (err) {
                            console.error('❌ Error creating conversation:', err);
                            res.status(500).json({ error: err.message });
                            return;
                        }
                        console.log('✅ Conversation created successfully on Mac:', id);
                        res.json({ id, message: 'Conversation created successfully on Mac' });
                    }
                );
            }
        }
    );
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    const healthData = {
        status: 'OK',
        server: 'Mac',
        hostname: os.hostname(),
        platform: os.platform(),
        arch: os.arch(),
        ip: LOCAL_IP,
        port: PORT,
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        connections: wss.clients.size,
        urls: {
            local: `http://localhost:${PORT}`,
            network: `http://${LOCAL_IP}:${PORT}`,
            websocket: `ws://${LOCAL_IP}:${PORT}/ws`
        }
    };
    console.log('🏥 Health check requested from Mac');
    res.json(healthData);
});

// Serve static files and info
app.get('/', (req, res) => {
    res.json({
        message: 'LeedsLink Backend running on Mac',
        hostname: os.hostname(),
        ip: LOCAL_IP,
        port: PORT,
        endpoints: {
            health: '/api/health',
            listings: '/api/listings',
            messages: '/api/messages',
            conversations: '/api/conversations'
        },
        websocket: `ws://${LOCAL_IP}:${PORT}/ws`,
        urls: {
            local: `http://localhost:${PORT}`,
            network: `http://${LOCAL_IP}:${PORT}`
        }
    });
});

// Handle 404
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Endpoint not found on Mac backend' });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 LeedsLink Backend running on Mac!`);
    console.log(`📱 Local access: http://localhost:${PORT}`);
    console.log(`🌐 Network access: http://${LOCAL_IP}:${PORT}`);
    console.log(`🔌 WebSocket: ws://${LOCAL_IP}:${PORT}/ws`);
    console.log(`📊 Health check: http://${LOCAL_IP}:${PORT}/api/health`);
    console.log(`💾 Database: leedslink-mac.db`);
    console.log(`⏰ Started at: ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('🛑 Shutting down LeedsLink backend on Mac...');
    db.close((err) => {
        if (err) {
            console.error(err.message);
        }
        console.log('💾 Database connection closed on Mac.');
        server.close(() => {
            console.log('🔌 Server closed on Mac.');
            process.exit(0);
        });
    });
});

// Error handling
process.on('uncaughtException', (err) => {
    console.error('💥 Uncaught Exception on Mac:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('💥 Unhandled Rejection on Mac:', reason);
});
