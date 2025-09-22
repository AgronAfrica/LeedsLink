const express = require('express');
const WebSocket = require('ws');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');

const app = express();
const server = require('http').createServer(app);
const wss = new WebSocket.Server({ server });

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Database setup
const db = new sqlite3.Database('leedslink.db');

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
    console.log('New WebSocket connection');
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('Received:', data);
            
            // Broadcast to all connected clients
            wss.clients.forEach(client => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(data));
                }
            });
        } catch (error) {
            console.error('Error parsing WebSocket message:', error);
        }
    });
    
    ws.on('close', () => {
        console.log('WebSocket connection closed');
    });
});

// Helper function to broadcast to all WebSocket clients
function broadcastToClients(type, data) {
    const message = JSON.stringify({ type, data });
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
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

// Create new listing
app.post('/api/listings', (req, res) => {
    const { userId, title, description, category, price, location, images } = req.body;
    const id = require('crypto').randomUUID();
    
    db.run(
        'INSERT INTO listings (id, userId, title, description, category, price, location, images) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [id, userId, title, description, category, price, location, JSON.stringify(images || [])],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            
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
            
            res.json({ id, message: 'Listing created successfully' });
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
                res.status(500).json({ error: err.message });
                return;
            }
            res.json(rows);
        }
    );
});

// Send a message
app.post('/api/messages', (req, res) => {
    const { conversationId, senderId, text } = req.body;
    const id = require('crypto').randomUUID();
    
    db.run(
        'INSERT INTO messages (id, conversationId, senderId, text) VALUES (?, ?, ?, ?)',
        [id, conversationId, senderId, text],
        function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            
            // Update conversation's last message
            db.run(
                'UPDATE conversations SET lastMessage = ?, lastMessageAt = CURRENT_TIMESTAMP WHERE id = ?',
                [text, conversationId]
            );
            
            // Broadcast new message to all connected clients
            broadcastToClients('new_message', {
                id,
                conversationId,
                senderId,
                text,
                timestamp: new Date().toISOString()
            });
            
            res.json({ id, message: 'Message sent successfully' });
        }
    );
});

// Create or get conversation
app.post('/api/conversations', (req, res) => {
    const { listingId, participants } = req.body;
    
    // Check if conversation already exists
    db.get(
        'SELECT * FROM conversations WHERE listingId = ? AND participants = ?',
        [listingId, JSON.stringify(participants.sort())],
        (err, row) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            
            if (row) {
                res.json({ id: row.id, message: 'Conversation already exists' });
            } else {
                // Create new conversation
                const id = require('crypto').randomUUID();
                db.run(
                    'INSERT INTO conversations (id, listingId, participants) VALUES (?, ?, ?)',
                    [id, listingId, JSON.stringify(participants)],
                    function(err) {
                        if (err) {
                            res.status(500).json({ error: err.message });
                            return;
                        }
                        res.json({ id, message: 'Conversation created successfully' });
                    }
                );
            }
        }
    );
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Serve static files (optional - for web admin interface)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`WebSocket server ready for connections`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('Shutting down server...');
    db.close((err) => {
        if (err) {
            console.error(err.message);
        }
        console.log('Database connection closed.');
        server.close(() => {
            console.log('Server closed.');
            process.exit(0);
        });
    });
});
