# APPENDICES

## APPENDIX A: INSTALLATION AND EXECUTION INSTRUCTIONS

### A.1 Prerequisites and Toolchain Setup
To compile, execute, and verify the Smart Asset Protection and Hidden Tracking System, ensure the following software toolchains are installed on the development host:
1. **Flutter SDK:** Version 3.13.x or higher (Dart SDK 3.1+). Ensure `flutter doctor` validates Android toolchain and VS Code / Android Studio plugins.
2. **Node.js:** Version 18.x LTS or 20.x LTS with `npm` package manager.
3. **MongoDB:** MongoDB Community Server (v6.0+) running locally on port 27017 or a valid connection URI to MongoDB Atlas Cloud.
4. **Physical Mobile Device:** An Android smartphone running Android 7.0+ (API 24+) with Bluetooth Low Energy and GPS hardware enabled, connected via USB debugging or Wi-Fi adb.

---

### A.2 Backend Service Installation and Execution
1. Navigate to the `backend/` directory in a terminal:
   ```bash
   cd backend
   ```
2. Install the necessary Node.js dependencies:
   ```bash
   npm install
   ```
3. Verify or create the `.env` configuration file in the `backend/` directory:
   ```env
   PORT=5000
   MONGO_URI=mongodb://127.0.0.1:27017/smart_asset_protection
   ```
4. Start the backend service:
   ```bash
   node server.js
   ```
   *Expected Output:*
   ```text
   Routes loaded successfully: /api/assets, /api/alerts, /api/history
   MongoDB Connected Successfully!
   Server running on port 5000
   ```

---

### A.3 Android Manifest Permission Configuration
Ensure `android/app/src/main/AndroidManifest.xml` includes the necessary runtime permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Location Permissions for GPS Geofencing -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Bluetooth Low Energy Permissions for Android 12+ (API 31+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
                     android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- Legacy Bluetooth Permissions for Android 11 and below -->
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />

    <!-- Network Access -->
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

---

### A.4 Mobile Client Execution
1. Return to the root project workspace:
   ```bash
   cd ..
   ```
2. Fetch Flutter package dependencies:
   ```bash
   flutter pub get
   ```
3. Connect a physical Android smartphone via USB (with Developer Options and USB Debugging enabled).
4. Run the application in debug mode:
   ```bash
   flutter run
   ```

<br>

---

## APPENDIX B: REPRESENTATIVE API ROUTES AND PAYLOADS

### B.1 Asset Creation Endpoint (`POST /api/assets`)
- **Request URL:** `http://localhost:5000/api/assets`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`

**Sample Request Body:**
```json
{
  "name": "ThinkPad P14s Workstation",
  "category": "Electronics",
  "description": "Department development laptop",
  "latitude": 18.00142,
  "longitude": 79.55219,
  "safeLocation": "SR University CS&AI Lab",
  "radius": 100,
  "userId": "default_user"
}
```

**Sample Response Body (HTTP 201 Created):**
```json
{
  "message": "Asset added successfully",
  "asset": {
    "_id": "67375a1b82e4f9b8c012a45e",
    "name": "ThinkPad P14s Workstation",
    "category": "Electronics",
    "description": "Department development laptop",
    "latitude": 18.00142,
    "longitude": 79.55219,
    "safeLocation": "SR University CS&AI Lab",
    "radius": 100,
    "trackerId": null,
    "trackerName": null,
    "trackerStatus": "unpaired",
    "lastRssi": null,
    "lastDetected": null,
    "userId": "default_user",
    "movementLatitude": null,
    "movementLongitude": null,
    "isOutside": false,
    "createdAt": "2026-11-20T05:30:11.102Z",
    "__v": 0
  }
}
```

---

### B.2 Security Alert Ingestion Endpoint (`POST /api/alerts`)
- **Request URL:** `http://localhost:5000/api/alerts`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`

**Sample Request Body:**
```json
{
  "title": "Geofence Perimeter Breach Detected",
  "assetId": "67375a1b82e4f9b8c012a45e",
  "assetName": "ThinkPad P14s Workstation",
  "description": "Host device departed designated safe haven (Distance: 142.6m > 100m).",
  "alertType": "safe_zone",
  "severity": "high",
  "userId": "default_user"
}
```

**Sample Response Body (HTTP 201 Created):**
```json
{
  "message": "Alert created successfully",
  "alert": {
    "_id": "67375b4f82e4f9b8c012a472",
    "title": "Geofence Perimeter Breach Detected",
    "assetId": "67375a1b82e4f9b8c012a45e",
    "assetName": "ThinkPad P14s Workstation",
    "description": "Host device departed designated safe haven (Distance: 142.6m > 100m).",
    "alertType": "safe_zone",
    "severity": "high",
    "isRead": false,
    "userId": "default_user",
    "timestamp": "2026-11-20T06:22:15.890Z",
    "__v": 0
  }
}
```

<br>

---

## APPENDIX C: APPLICATION SCREEN INVENTORY AND UI WALKTHROUGH

The application interface consists of seven functional views:

1. **Dashboard View (`homeScreen()`):**
   - Displays real-time metric cards summarizing total assets, active BLE connections, and unread security alerts.
   - Provides quick-action routing buttons for asset registration, BLE scanning, and map inspection.
   - Visualizes overall system health with status badges.
2. **Protected Assets View (`assetsScreen()`):**
   - Renders registered assets as interactive cards detailing category icons, safe-zone labels, paired tracker MACs, and geofence radii.
   - Provides an action button triggering a modal registration dialog to create new assets.
   - Enables editing and deletion of existing asset records.
3. **Bluetooth BLE Tracker View (`trackerScreen()`):**
   - Provides manual controls to start and stop 2.4 GHz scanning.
   - Renders discovered BLE peripherals with device names, MAC addresses, and live RSSI meters.
   - Supports GATT connection pairing and service discovery.
4. **Geofence & Movement Map View (`locationScreen()`):**
   - Embeds interactive OpenStreetMap raster tiles centered on the user's current GPS position.
   - Displays safe zones as colored radial circles around defined centroids.
   - Supports interactive coordinate selection via map taps.
5. **Security Alerts View (`alertsScreen()`):**
   - Displays a chronological feed of security events with color-coded severity badges.
   - Provides controls to mark individual alerts as read or acknowledge all alerts at once.
6. **Location & Event History View (`historyScreen()`):**
   - Details an audit log of recorded GPS coordinates, geofence statuses, and RSSI metrics.
   - Allows users to review movement timelines and incident histories.
7. **Settings & Network View (`settingsScreen()`):**
   - Allows configuration of the backend REST API base URL.
   - Provides a slider to adjust the RSSI alert threshold (default: $-80\text{ dBm}$).
   - Includes a toggle to activate simulation mode for academic presentations.

<br>

---

## APPENDIX D: IMPORTANT SOURCE CODE LISTINGS

### D.1 Backend Route Handler: Alert De-Duplication (`backend/routes/alertRoutes.js`)
```javascript
const express = require('express');
const router = express.Router();
const Alert = require('../models/Alert');

// Ingest new security alert with 60-second temporal de-duplication
router.post('/', async (req, res) => {
    try {
        const { title, assetId, assetName, description, alertType, severity, userId } = req.body;

        // Query for an existing alert with identical title & asset within last 60 seconds
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

module.exports = router;
```

---

### D.2 Mobile Client: Geofence Distance Calculation (`lib/main.dart`)
```dart
void checkGeofenceBreach(Position currentPos, Map<String, dynamic> asset) {
  if (asset['latitude'] == null || asset['longitude'] == null) return;

  // Compute spherical distance using Haversine formula
  double distanceInMeters = Geolocator.distanceBetween(
    asset['latitude'],
    asset['longitude'],
    currentPos.latitude,
    currentPos.longitude,
  );

  double safeRadius = (asset['radius'] as num).toDouble();

  if (distanceInMeters > safeRadius) {
    triggerSecurityAlert(
      title: 'Geofence Breach Detected',
      assetName: asset['name'],
      description: 'Host device moved ${distanceInMeters.toStringAsFixed(1)}m away '
                   '(Safe Radius: ${safeRadius.toInt()}m).',
      alertType: 'safe_zone',
      severity: 'high',
    );
  }
}
```

---

### D.3 Mobile Client: RSSI Proximity Categorization (`lib/main.dart`)
```dart
String getRssiCategory(int rssi) {
  if (rssi >= -60) {
    return 'Immediate (< 1.5m)';
  } else if (rssi >= -75) {
    return 'Near (1.5m - 5m)';
  } else if (rssi >= -85) {
    return 'Far (5m - 15m)';
  } else {
    return 'Very Far / Lost (> 15m)';
  }
}

Color getRssiColor(int rssi) {
  if (rssi >= -60) return Colors.green;
  if (rssi >= -75) return Colors.teal;
  if (rssi >= -85) return Colors.amber;
  return Colors.red;
}
```
