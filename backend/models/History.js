const mongoose = require('mongoose');

const historySchema = new mongoose.Schema({
    assetId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Asset',
        default: null
    },
    assetName: {
        type: String,
        required: true
    },
    safeName: {
        type: String,
        default: ''
    },
    latitude: {
        type: Number,
        required: true
    },
    longitude: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        default: 'Inside Safe Zone'
    },
    historyType: {
        type: String,
        enum: ['gps', 'tracker', 'geofence'],
        default: 'gps'
    },
    rssi: {
        type: Number,
        default: null
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

module.exports = mongoose.model('History', historySchema);
