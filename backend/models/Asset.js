const mongoose = require('mongoose');

const assetSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    category: {
        type: String,
        required: true
    },
    description: {
        type: String,
        default: ''
    },
    latitude: {
        type: Number,
        default: null
    },
    longitude: {
        type: Number,
        default: null
    },
    safeLocation: {
        type: String,
        default: ''
    },
    radius: {
        type: Number,
        default: 100
    },
    // Tracker integration fields
    trackerId: {
        type: String,
        default: null
    },
    trackerName: {
        type: String,
        default: null
    },
    trackerStatus: {
        type: String,
        enum: ['connected', 'disconnected', 'searching', 'unpaired'],
        default: 'unpaired'
    },
    lastRssi: {
        type: Number,
        default: null
    },
    lastDetected: {
        type: Date,
        default: null
    },
    // User association
    userId: {
        type: String,
        default: 'default_user'
    },
    // Live tracking status
    movementLatitude: {
        type: Number,
        default: null
    },
    movementLongitude: {
        type: Number,
        default: null
    },
    isOutside: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Asset', assetSchema);
