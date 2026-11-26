const express = require('express');
const router = express.Router();
const History = require('../models/History');

// Get history
router.get('/', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        if (req.query.assetName) {
            filter.assetName = req.query.assetName;
        }
        if (req.query.historyType) {
            filter.historyType = req.query.historyType;
        }

        const limit = parseInt(req.query.limit) || 100;
        const history = await History.find(filter).sort({ timestamp: -1 }).limit(limit);
        res.json(history);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Add history entry
router.post('/', async (req, res) => {
    try {
        const { assetId, assetName, safeName, latitude, longitude, status, historyType, rssi, userId } = req.body;

        const entry = new History({
            assetId: assetId || null,
            assetName,
            safeName: safeName || '',
            latitude,
            longitude,
            status: status || 'Inside Safe Zone',
            historyType: historyType || 'gps',
            rssi: rssi !== undefined ? rssi : null,
            userId: userId || 'default_user',
            timestamp: new Date()
        });

        await entry.save();
        res.status(201).json({
            message: 'History recorded successfully',
            history: entry
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete history
router.delete('/', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        await History.deleteMany(filter);
        res.json({ message: 'History cleared successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
