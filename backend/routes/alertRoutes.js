const express = require('express');
const router = express.Router();
const Alert = require('../models/Alert');

// Get all alerts
router.get('/', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        const limit = parseInt(req.query.limit) || 50;
        const alerts = await Alert.find(filter).sort({ timestamp: -1 }).limit(limit);
        res.json(alerts);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Create new alert (with de-duplication check within 60 seconds)
router.post('/', async (req, res) => {
    try {
        const { title, assetId, assetName, description, alertType, severity, userId } = req.body;

        // Prevent duplicate alerts with same title and asset within last 60 seconds
        const sixtySecondsAgo = new Date(Date.now() - 60 * 1000);
        const existing = await Alert.findOne({
            title,
            assetName,
            timestamp: { $gte: sixtySecondsAgo }
        });

        if (existing) {
            return res.status(200).json({
                message: 'Duplicate alert suppressed',
                alert: existing
            });
        }

        const alert = new Alert({
            title,
            assetId: assetId || null,
            assetName: assetName || 'System',
            description,
            alertType: alertType || 'system',
            severity: severity || 'medium',
            userId: userId || 'default_user',
            timestamp: new Date()
        });

        await alert.save();
        res.status(201).json({
            message: 'Alert created successfully',
            alert
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Mark single alert as read
router.patch('/:id/read', async (req, res) => {
    try {
        const alert = await Alert.findByIdAndUpdate(
            req.params.id,
            { isRead: true },
            { new: true }
        );
        if (!alert) {
            return res.status(404).json({ message: 'Alert not found' });
        }
        res.json({ message: 'Alert marked as read', alert });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Mark all alerts as read
router.patch('/mark-all-read', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        await Alert.updateMany(filter, { isRead: true });
        res.json({ message: 'All alerts marked as read' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Delete all alerts
router.delete('/', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        await Alert.deleteMany(filter);
        res.json({ message: 'Alerts cleared successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
