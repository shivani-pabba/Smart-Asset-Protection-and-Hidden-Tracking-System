const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    assetId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Asset',
        default: null
    },
    assetName: {
        type: String,
        default: 'System'
    },
    description: {
        type: String,
        required: true
    },
    alertType: {
        type: String,
        enum: ['safe_zone', 'tracker_disconnected', 'tracker_not_detected', 'weak_rssi', 'system'],
        default: 'system'
    },
    severity: {
        type: String,
        enum: ['low', 'medium', 'high', 'critical'],
        default: 'medium'
    },
    isRead: {
        type: Boolean,
        default: false
    },
    userId: {
        type: String,
        default: 'default_user'
    },
    timestamp: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Alert', alertSchema);
