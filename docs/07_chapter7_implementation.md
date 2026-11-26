# CHAPTER 7 – IMPLEMENTATION

## 7.1 INTRODUCTION
Implementation translates system designs, architectural models, and algorithmic formulations into functional, executable software. Developing the **Smart Asset Protection and Hidden Tracking System** required synthesizing multiple programming paradigms across mobile engineering, network protocols, hardware sensor interfacing, and cloud database persistence.

This chapter details the technical implementation of the system. It covers:
- The development environment and runtime dependency stack.
- The cross-platform mobile frontend implementation in Flutter and Dart.
- The RESTful backend middleware implementation in Node.js and Express.js.
- The database models and Mongoose integration in MongoDB.
- The mobile GNSS/GPS subsystem implementation using `geolocator` and `geocoding`.
- The Bluetooth Low Energy scanning and GATT discovery implementation using `flutter_blue_plus`.
- The algorithmic implementation of the RSSI proximity categorization engine.
- System integration and end-to-end communication pipelines.

---

## 7.2 DEVELOPMENT ENVIRONMENT
The development environment was configured to support cross-platform mobile compilation and asynchronous backend web service execution.

**Table 7.1: Core Software Development Dependencies and Versioning**
| Architectural Layer | Software Package / Dependency | Version Specification | Operational Role |
| :--- | :--- | :--- | :--- |
| **Mobile Client** | Flutter SDK | `^3.13.7` (Dart 3.1+) | Core cross-platform mobile UI framework |
| &nbsp; | `geolocator` | `^14.1.2` | Native GNSS location acquisition and distance calculations |
| &nbsp; | `geocoding` | `^5.0.1` | Asynchronous reverse geocoding of coordinates to addresses |
| &nbsp; | `flutter_blue_plus` | `^2.3.15` | Native Bluetooth Low Energy scanning and GATT management |
| &nbsp; | `flutter_map` | `^8.3.2` | Interactive vector map rendering (OpenStreetMap tiles) |
| &nbsp; | `latlong2` | `^0.10.1` | Latitude and longitude geometric calculations |
| &nbsp; | `http` | `^1.6.0` | Asynchronous HTTP client for RESTful API communication |
| &nbsp; | `shared_preferences` | `^2.5.6` | Persistent local key-value storage for offline resilience |
| &nbsp; | `permission_handler`| `^13.0.2` | Runtime Android and iOS permission negotiation |
| **Backend Service**| Node.js Runtime | `v18.x LTS / v20.x` | Asynchronous JavaScript event-driven server runtime |
| &nbsp; | Express.js | `^4.18.2` | Minimalist web application and REST routing framework |
| &nbsp; | Mongoose ODM | `^7.5.0` | Object Data Modeling library for MongoDB schema management |
| &nbsp; | CORS | `^2.8.5` | Cross-Origin Resource Sharing middleware |
| &nbsp; | Dotenv | `^16.3.1` | Environment variable management from `.env` files |
| **Database Engine** | MongoDB Server | `v6.0+ / v7.0+` | Distributed NoSQL document database |

---

## 7.3 FRONTEND IMPLEMENTATION
The client frontend is developed in Flutter and Dart, organized in `lib/main.dart` (encompassing 2,887 lines of modular, declarative UI code). The root widget `SmartAssetApp` initializes a Material 3 design system with customized color schemes (deep indigo and cyan accents).

### 7.3.1 State Management Architecture
The application state is encapsulated within `_HomePageState`. Key state variables manage navigation, asset inventory, sensor telemetry, and alerts:

```dart
class _HomePageState extends State<HomePage> {
  // Navigation State
  int selectedIndex = 0;

  // Asset Inventory State
  final List<Map<String, dynamic>> assets = [];
  int? selectedAssetIndex;

  // Security Alerts State
  final List<Map<String, dynamic>> securityAlerts = [];
  final Set<String> _recentAlertKeys = {};

  // Location & Geofencing State
  Position? currentPosition;
  LatLng? selectedMapPoint;
  bool isGettingLocation = false;
  String locationMessage = 'Location not fetched yet.';
  String placeName = 'Place name not available';
  final MapController mapController = MapController();
  final List<Map<String, dynamic>> locationHistory = [];

  // Bluetooth Low Energy State
  bool isBleScanning = false;
  bool trackerConnected = false;
  BluetoothDevice? connectedBleDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<ScanResult> discoveredDevices = [];
  List<BluetoothService> discoveredServices = [];

  // Continuous RSSI Monitoring State
  int? currentRssi;
  DateTime? lastRssiTimestamp;
  Timer? _rssiMonitorTimer;
  int weakRssiConsecutiveCount = 0;
  int rssiAlertThreshold = -80; // Configurable alert threshold in dBm
```

### 7.3.2 Screen Flow and Navigation
The main scaffold uses an `IndexedStack` to preserve screen state across tab switches, navigated via a persistent bottom `NavigationBar`:
- Index 0: `homeScreen()` – System overview dashboard.
- Index 1: `assetsScreen()` – Asset management and registration.
- Index 2: `trackerScreen()` – BLE scanning and RSSI inspection.
- Index 3: `locationScreen()` – Interactive geofence and movement map.
- Index 4: `alertsScreen()` – Security notifications feed.
- Index 5: `historyScreen()` – Spatial telemetry audit log.
- Index 6: `settingsScreen()` – Configuration and simulation toggles.

---

## 7.4 BACKEND IMPLEMENTATION
The backend service is engineered in Node.js and Express.js, structured across `server.js`, `models/`, and `routes/`.

### 7.4.1 Server Bootstrapping (`server.js`)
The main server script initializes middleware, imports route handlers, establishes database connectivity, and binds the HTTP listener:

```javascript
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '.env') });

const assetRoutes = require('./routes/assetRoutes');
const alertRoutes = require('./routes/alertRoutes');
const historyRoutes = require('./routes/historyRoutes');

const app = express();
app.use(cors());
app.use(express.json());

// Mount API routes
app.use('/api/assets', assetRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/history', historyRoutes);

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/smart_asset_protection';
const PORT = process.env.PORT || 5000;

mongoose.connect(MONGO_URI)
    .then(() => {
        console.log('MongoDB Connected Successfully!');
        app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
    })
    .catch((error) => {
        console.log('MongoDB Connection Error:', error.message);
        // Fallback: Start HTTP server to allow offline/cached responses
        app.listen(PORT, () => console.log(`Server running in offline/cache mode on port ${PORT}`));
    });
```

### 7.4.2 RESTful API Route Endpoints
Table 7.2 outlines the REST API routes implemented across the backend microservices.

**Table 7.2: Implemented Express.js REST API Route Specifications**
| HTTP Method | Route Endpoint | Target Controller File | Primary Operational Purpose |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/assets` | `assetRoutes.js` | Ingests and persists a new asset document. |
| `GET` | `/api/assets` | `assetRoutes.js` | Retrieves all registered assets (with optional `userId` filter). |
| `GET` | `/api/assets/:id` | `assetRoutes.js` | Fetches full document details for a specific asset by ID. |
| `PUT` | `/api/assets/:id` | `assetRoutes.js` | Updates an asset's descriptive or geofence parameters. |
| `PATCH`| `/api/assets/:id/tracker`| `assetRoutes.js` | Updates paired BLE tracker connection status and last RSSI. |
| `DELETE`| `/api/assets/:id` | `assetRoutes.js` | Deletes an asset document from the database. |
| `GET` | `/api/alerts` | `alertRoutes.js` | Returns chronologically sorted security alerts. |
| `POST` | `/api/alerts` | `alertRoutes.js` | Ingests alerts with 60-second temporal deduplication. |
| `PATCH`| `/api/alerts/:id/read` | `alertRoutes.js` | Marks an individual security alert as acknowledged/read. |
| `PATCH`| `/api/alerts/mark-all-read` | `alertRoutes.js` | Marks all security alerts for a user as read. |
| `DELETE`| `/api/alerts` | `alertRoutes.js` | Clears all security alert records from the database. |
| `GET` | `/api/history` | `historyRoutes.js` | Retrieves historical spatial telemetry records. |
| `POST` | `/api/history` | `historyRoutes.js` | Appends a new timestamped GPS/RSSI telemetry entry. |
| `DELETE`| `/api/history` | `historyRoutes.js` | Purges historical telemetry records for a user. |

---

## 7.5 DATABASE IMPLEMENTATION
Database schemas are implemented using Mongoose ODM, mapping JavaScript data structures directly to MongoDB BSON documents.

### 7.5.1 The Asset Model (`models/Asset.js`)
The `Asset` schema enforces data types, required fields, and state enumerations:

```javascript
const mongoose = require('mongoose');

const assetSchema = new mongoose.Schema({
    name: { type: String, required: true },
    category: { type: String, required: true },
    description: { type: String, default: '' },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    safeLocation: { type: String, default: '' },
    radius: { type: Number, default: 100 },
    trackerId: { type: String, default: null },
    trackerName: { type: String, default: null },
    trackerStatus: {
        type: String,
        enum: ['connected', 'disconnected', 'searching', 'unpaired'],
        default: 'unpaired'
    },
    lastRssi: { type: Number, default: null },
    lastDetected: { type: Date, default: null },
    userId: { type: String, default: 'default_user' },
    movementLatitude: { type: Number, default: null },
    movementLongitude: { type: Number, default: null },
    isOutside: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Asset', assetSchema);
```

### 7.5.2 The Alert Model (`models/Alert.js`)
The `Alert` schema captures security events with severity levels:

```javascript
const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
    title: { type: String, required: true },
    assetId: { type: mongoose.Schema.Types.ObjectId, ref: 'Asset', default: null },
    assetName: { type: String, default: 'System' },
    description: { type: String, required: true },
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
    isRead: { type: Boolean, default: false },
    userId: { type: String, default: 'default_user' },
    timestamp: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Alert', alertSchema);
```

---

## 7.6 GPS MODULE IMPLEMENTATION
The GPS module interfaces with native device GNSS receivers using the `geolocator` package.

### 7.6.1 Runtime Permission Handling and Position Acquisition
Before querying location services, the application checks service status and requests runtime permissions:

```dart
Future<void> fetchCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    setState(() => locationMessage = 'Location services are disabled.');
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() => locationMessage = 'Location permissions are denied.');
      return;
    }
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  setState(() {
    currentPosition = position;
    locationMessage = 'Lat: ${position.latitude.toStringAsFixed(5)}, '
                      'Lon: ${position.longitude.toStringAsFixed(5)}';
  });

  // Perform reverse geocoding
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        placeName = '${place.name}, ${place.subLocality}, ${place.locality}';
      });
    }
  } catch (e) {
    setState(() => placeName = 'Reverse geocoding unavailable');
  }
}
```

### 7.6.2 Haversine Geofence Boundary Check Implementation
The geofence evaluation function computes spherical distance between the host smartphone and the asset's safe centroid:

```dart
void checkGeofenceBreach(Position currentPos, Map<String, dynamic> asset) {
  if (asset['latitude'] == null || asset['longitude'] == null) return;

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
      description: 'Asset moved ${distanceInMeters.toStringAsFixed(1)}m away '
                   '(Safe Radius: ${safeRadius}m).',
      alertType: 'safe_zone',
      severity: 'high',
    );
  }
}
```

---

## 7.7 BLE MODULE IMPLEMENTATION
The Bluetooth Low Energy subsystem is implemented using the `flutter_blue_plus` package, managing adapter state verification, scanning, and GATT connection handling.

### 7.7.1 Asynchronous BLE Scanning Implementation
```dart
Future<void> startBleScan() async {
  if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
    setState(() => bluetoothMessage = 'Please enable Bluetooth on your device.');
    return;
  }

  setState(() {
    isBleScanning = true;
    discoveredDevices.clear();
    bluetoothMessage = 'Scanning for nearby BLE devices...';
  });

  // Listen to scan results stream
  _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
    setState(() {
      discoveredDevices = results;
    });
  });

  // Start scanning with a 15-second timeout
  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

  setState(() {
    isBleScanning = false;
    bluetoothMessage = 'Scan completed. Found ${discoveredDevices.length} devices.';
  });
}
```

### 7.7.2 GATT Peripheral Connection and Service Interrogation
When a user selects a compatible device from the scan list, the application establishes a GATT connection:

```dart
Future<void> connectToDevice(BluetoothDevice device) async {
  await device.connect(autoConnect: false);
  
  setState(() {
    connectedBleDevice = device;
    trackerConnected = true;
  });

  // Discover supported GATT services
  List<BluetoothService> services = await device.discoverServices();
  setState(() {
    discoveredServices = services;
  });

  // Start periodic RSSI monitoring
  _startRssiMonitoring(device);
}
```

---

## 7.8 RSSI-BASED PROXIMITY ESTIMATION IMPLEMENTATION
To provide actionable proximity feedback without misleading metric distance claims, the system classifies raw RSSI measurements into discrete proximity tiers:

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

### Continuous RSSI Polling Loop
A periodic `Timer` reads the signal strength from the connected peripheral every 2 seconds:

```dart
void _startRssiMonitoring(BluetoothDevice device) {
  _rssiMonitorTimer?.cancel();
  _rssiMonitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
    try {
      int rssi = await device.readRssi();
      setState(() {
        currentRssi = rssi;
        lastRssiTimestamp = DateTime.now();
      });

      // Check if RSSI is below the user-configured alert threshold
      if (rssi < rssiAlertThreshold) {
        weakRssiConsecutiveCount++;
        if (weakRssiConsecutiveCount >= 3) {
          triggerSecurityAlert(
            title: 'Weak Tracker Signal Warning',
            assetName: device.platformName.isNotEmpty ? device.platformName : 'BLE Tracker',
            description: 'Signal degraded to $rssi dBm. Asset may be moving out of range.',
            alertType: 'weak_rssi',
            severity: 'medium',
          );
        }
      } else {
        weakRssiConsecutiveCount = 0;
      }
    } catch (e) {
      // Handle read timeout or disconnection
    }
  });
}
```

---

## 7.9 INTEGRATION OF MODULES
The complete system operates through continuous integration between the mobile client and the backend REST services.

### 7.9.1 RESTful API Dispatch Helper
The mobile client handles HTTP communication via a unified helper:

```dart
Future<void> syncAssetWithBackend(Map<String, dynamic> assetData) async {
  final url = Uri.parse('$backendBaseUrl/api/assets');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(assetData),
    );

    if (response.statusCode == 201) {
      print('Asset synchronized with cloud database.');
    } else {
      print('Backend sync error: ${response.statusCode}');
    }
  } catch (e) {
    print('Network unreachable. Caching asset locally in SharedPreferences.');
    saveAssetToLocalStorage(assetData);
  }
}
```

---

## 7.10 SUMMARY
This chapter detailed the software implementation of the Smart Asset Protection and Hidden Tracking System. The runtime software stack and dependencies were documented. The Flutter frontend implementation—including state management in `_HomePageState` and screen navigation—was presented. The Node.js/Express backend implementation, REST endpoints, and Mongoose document models were detailed with code excerpts. Native hardware integration for GPS positioning (`geolocator`), reverse geocoding (`geocoding`), and BLE scanning/connection (`flutter_blue_plus`) was explained. Finally, the algorithmic implementation of the RSSI proximity categorization engine and backend integration pipelines were presented. The next chapter presents the experimental results and discussion.
