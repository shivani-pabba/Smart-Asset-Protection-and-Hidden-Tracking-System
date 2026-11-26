const express = require('express');
const router = express.Router();
const Asset = require('../models/Asset');

// Add asset
router.post('/', async (req, res) => {
    try {
        const asset = new Asset(req.body);
        await asset.save();

        res.status(201).json({
            message: 'Asset added successfully',
            asset
        });
    } catch (error) {
        res.status(400).json({
            message: error.message
        });
    }
});

// Get all assets
router.get('/', async (req, res) => {
    try {
        const filter = {};
        if (req.query.userId) {
            filter.userId = req.query.userId;
        }
        const assets = await Asset.find(filter).sort({ createdAt: -1 });
        res.json(assets);
    } catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
});

// Get single asset
router.get('/:id', async (req, res) => {
    try {
        const asset = await Asset.findById(req.params.id);
        if (!asset) {
            return res.status(404).json({ message: 'Asset not found' });
        }
        res.json(asset);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update asset
router.put('/:id', async (req, res) => {
    try {
        const asset = await Asset.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!asset) {
            return res.status(404).json({ message: 'Asset not found' });
        }

        res.json({
            message: 'Asset updated successfully',
            asset
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Update asset tracker status / RSSI
router.patch('/:id/tracker', async (req, res) => {
    try {
        const { trackerId, trackerName, trackerStatus, lastRssi } = req.body;
        const updateData = {};
        if (trackerId !== undefined) updateData.trackerId = trackerId;
        if (trackerName !== undefined) updateData.trackerName = trackerName;
        if (trackerStatus !== undefined) updateData.trackerStatus = trackerStatus;
        if (lastRssi !== undefined) {
            updateData.lastRssi = lastRssi;
            updateData.lastDetected = new Date();
        }

        const asset = await Asset.findByIdAndUpdate(
            req.params.id,
            { $set: updateData },
            { new: true }
        );

        if (!asset) {
            return res.status(404).json({ message: 'Asset not found' });
        }

        res.json({
            message: 'Asset tracker updated successfully',
            asset
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete asset
router.delete('/:id', async (req, res) => {
    try {
        const asset = await Asset.findByIdAndDelete(req.params.id);

        if (!asset) {
            return res.status(404).json({
                message: 'Asset not found'
            });
        }

        res.json({
            message: 'Asset deleted successfully'
        });
    } catch (error) {
        res.status(400).json({
            message: error.message
        });
    }
});

module.exports = router;
