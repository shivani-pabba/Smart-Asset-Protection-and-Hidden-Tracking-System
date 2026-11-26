const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const path = require('path');

// Ensure .env is loaded regardless of current working directory
require('dotenv').config({ path: path.join(__dirname, '.env') });

// Import routes
const authRoutes = require('./routes/authRoutes');
const assetRoutes = require('./routes/assetRoutes');
const alertRoutes = require('./routes/alertRoutes');
const historyRoutes = require('./routes/historyRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Home route
app.get('/', (req, res) => {
    res.send('Smart Asset Protection Backend is Running!');
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/assets', assetRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/history', historyRoutes);

console.log('Routes loaded successfully: /api/auth, /api/assets, /api/alerts, /api/history');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/smart_asset_protection';
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
mongoose.connect(MONGO_URI)
    .then(() => {
        console.log('MongoDB Connected Successfully!');
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch((error) => {
        console.log('MongoDB Connection Error:', error.message);
        // Start HTTP server anyway so endpoints respond even if MongoDB daemon is starting up
        app.listen(PORT, () => {
            console.log(`Server running in offline/cache mode on port ${PORT}`);
        });
    });
