# CHAPTER 6 – SYSTEM DESIGN AND ARCHITECTURE

## 6.1 INTRODUCTION
System design translates software requirements and operational methodologies into concrete structural blueprints. An asset protection system handling physical sensor streams, low-latency radio communication, and persistent spatial auditing requires a robust, scalable, and decoupled architectural foundation.

This chapter details the architectural design of the **Smart Asset Protection and Hidden Tracking System**. It presents:
- The overarching three-tier client-server architecture.
- The internal structural organization of the Flutter mobile client frontend.
- The layered service design of the Node.js/Express REST backend.
- The database schema organization and relationship mappings.
- The dual-sensor GPS and BLE hardware abstraction module designs.
- Comprehensive Data Flow Diagrams (DFD Level 0, Level 1, and Level 2).
- Structural Unified Modeling Language (UML) diagrams, including Use Case, Activity, and Sequence diagrams.
- System reliability and security engineering protocols.

---

## 6.2 SYSTEM ARCHITECTURE
The system is architectured following the **Three-Tier Client-Server Architectural Pattern**, depicted in Figure 6.1. This pattern decouples user presentation, business logic execution, and data persistence into distinct, independently maintainable tiers.

```
+---------------------------------------------------------------------------------------------------+
|                        HIGH-LEVEL THREE-TIER SYSTEM ARCHITECTURE                                  |
+---------------------------------------------------------------------------------------------------+

 +=================================================================================================+
 |                                   PRESENTATION LAYER (CLIENT TIER)                              |
 |                                                                                                 |
 |   [ Cross-Platform Mobile Application (Flutter & Dart Engine) ]                                |
 |                                                                                                 |
 |   +------------------------------------+   +------------------------------------------------+   |
 |   |        USER INTERFACE VIEWS        |   |           HARDWARE SENSOR CONTROLLERS          |   |
 |   | - Home Screen (System Overview)    |   | - GPS Location Controller (geolocator)         |   |
 |   | - Asset Inventory Screen (CRUD)    |   | - Reverse Geocoding Controller (geocoding)      |   |
 |   | - BLE Tracker Management Screen    |   | - BLE Scanner & GATT Engine (flutter_blue_plus)|   |
 |   | - Geofence Map View (flutter_map)  |   | - Local Shared Preferences Cache Engine        |   |
 |   | - Security Alerts & History Screen |   | - Audio & Haptic Notification Dispatcher       |   |
 |   +------------------------------------+   +------------------------------------------------+   |
 +=================================================================================================+
                                                  |
                                                  |  Stateless RESTful APIs over HTTPS / JSON
                                                  v
 +=================================================================================================+
 |                                 APPLICATION LAYER (MIDDLEWARE TIER)                             |
 |                                                                                                 |
 |   [ Asynchronous RESTful Microservice Engine (Node.js Runtime & Express.js Framework) ]         |
 |                                                                                                 |
 |   +------------------------------------+   +------------------------------------------------+   |
 |   |          HTTP ROUTING LAYER        |   |            BUSINESS LOGIC CONTROLLERS          |   |
 |   | - /api/assets  (Asset Management)  |   | - Asset Validation & Serialization Controller  |   |
 |   | - /api/alerts  (Security Events)   |   | - Tracker Status & Link State Manager          |   |
 |   | - /api/history (Spatial Telemetry) |   | - 60-Second Alert De-Duplication Engine        |   |
 |   +------------------------------------+   +------------------------------------------------+   |
 +=================================================================================================+
                                                  |
                                                  |  Binary JSON (BSON) over TCP (Port 27017)
                                                  v
 +=================================================================================================+
 |                                  DATA LAYER (PERSISTENCE TIER)                                  |
 |                                                                                                 |
 |   [ Document-Oriented NoSQL Database (MongoDB Community Server / MongoDB Atlas) ]               |
 |                                                                                                 |
 |   +------------------------------------+   +------------------------------------------------+   |
 |   |          DATABASE COLLECTIONS      |   |            STORAGE & INDEXING ENGINE           |   |
 |   | - `assets`     (Asset Definitions) |   | - WiredTiger Memory-Mapped Storage Engine      |   |
 |   | - `alerts`     (Incident Logs)     |   | - B-Tree Indexes on `createdAt` & `timestamp`  |   |
 |   | - `histories`  (Spatial Telemetry) |   | - Compound Indexes on `userId` & `assetName`   |   |
 |   +------------------------------------+   +------------------------------------------------+   |
 +=================================================================================================+
```
*Figure 6.1: High-Level Three-Tier System Architecture*

### Layer Decomposition:
1. **Presentation Layer (Mobile Client):** Developed in Flutter/Dart, this layer executes on the user's mobile device (Android or iOS). It manages the graphical user interface, captures tactile user inputs, interfaces directly with native operating system location and Bluetooth radios, evaluates geofences locally, and renders real-time tracking dashboards.
2. **Application Layer (Backend Middleware):** Developed in Node.js and Express.js, this stateless layer exposes structured RESTful endpoints. It validates incoming JSON payloads, handles business logic (such as alert deduplication and tracker status reconciliation), and acts as a secure intermediary between the mobile client and the database.
3. **Data Layer (Persistence Engine):** Managed by MongoDB, this layer stores BSON documents across dedicated collections. It maintains primary and secondary indexes, enforces schema validations through Mongoose, and ensures persistent storage across system reboots.

---

## 6.3 FRONTEND DESIGN
The mobile client frontend is engineered as a declarative, reactive single-application architecture using Flutter. 

### 6.3.1 Widget Hierarchy and Navigation Flow
The Flutter application structure is anchored by `SmartAssetApp`, which instantiates `HomePage` governed by `_HomePageState`. The application provides seven dedicated functional views:
- **`homeScreen()` (Dashboard):** Displays real-time operational statistics, active asset counts, connected BLE status indicators, quick-action shortcuts, and system health badges.
- **`assetsScreen()` (Inventory Management):** Renders interactive asset cards with category icons, safe-zone labels, paired tracker details, and modal action dialogs for adding, editing, and deleting assets.
- **`trackerScreen()` (Bluetooth BLE Manager):** Manages native Bluetooth adapter states, triggers asynchronous scanning, renders discovered peripheral lists with live RSSI meters, and handles GATT connection pairing.
- **`locationScreen()` (Geofence & Movement Map):** Integrates `flutter_map` with OpenStreetMap raster tiles, rendering user coordinates, safe-zone centroid markers, circular geofence boundary overlays, and interactive coordinate pickers.
- **`alertsScreen()` (Security Feed):** Presents a chronological list of security events with color-coded severity badges (Low, Medium, High, Critical), filter controls, and a mark-all-as-read action.
- **`historyScreen()` (Spatial Audit Log):** Displays a timestamped historical timeline of recorded spatial coordinates, status flags, and RSSI metrics.
- **`settingsScreen()` (Network & Configuration):** Provides runtime configuration controls, allowing users to modify the backend API base URL, calibrate the RSSI alert threshold slider, and toggle simulation mode.

Figure 6.2 illustrates the decoupled client-server interaction pipeline.

```
+---------------------------------------------------------------------------------------------------+
|                        DECOUPLED CLIENT-SERVER INTERACTION PIPELINE                               |
+---------------------------------------------------------------------------------------------------+

     [ Flutter Client UI ] <---> [ State Manager (_HomePageState) ]
                                            |
                         +------------------+------------------+
                         |                                     |
                         v                                     v
             [ Native Hardware APIs ]               [ HTTP Network Client ]
             - Geolocator Position Stream           - http.post('/api/assets')
             - FlutterBluePlus BLE Stream           - http.get('/api/alerts')
             - SharedPreferences Flash Cache        - http.post('/api/history')
                         |                                     |
                         v                                     v
             [ Local Event Processing ]             [ Node.js / Express Server ]
             - Haversine Distance Calc                             |
             - RSSI Proximity Tiering               [ Mongoose ODM Layer ]
             - Audio/Visual Notification Dispatch                  |
                                                    [ MongoDB Persistence Engine ]
```
*Figure 6.2: Decoupled Client-Server Interaction Pipeline*

---

## 6.4 BACKEND DESIGN
The backend service is engineered using Node.js and Express.js, following a modular, layered architectural structure.

### 6.4.1 Modular Component Decomposition
The backend directory structure partitions concerns into dedicated modules:
- **`server.js` (Application Entry Point):** Bootstraps the Express application, configures middleware (CORS, JSON body parser), establishes persistent database connections via Mongoose, mounts API routers, and initiates the HTTP server on a configurable port.
- **`models/` (Data Access Layer):** Contains Mongoose schema definitions:
  - `Asset.js`: Defines asset metadata, geofence parameters, and BLE tracker status.
  - `Alert.js`: Defines security incidents, alert types, severities, and timestamps.
  - `History.js`: Defines historical spatial telemetry coordinates and RSSI metrics.
- **`routes/` (Controller and Routing Layer):** Encapsulates route handlers and business logic:
  - `assetRoutes.js`: Exposes endpoints for creating, retrieving, updating, patching tracker state, and deleting assets.
  - `alertRoutes.js`: Exposes endpoints for retrieving, deduplicating, marking read, and clearing security alerts.
  - `historyRoutes.js`: Exposes endpoints for logging and querying spatial telemetry records.

---

## 6.5 DATABASE DESIGN
The database design organizes application state into normalized BSON documents within MongoDB. 

### 6.5.1 Schema Normalization and Relationships
While MongoDB is inherently non-relational, the system maintains logical entity references between collections using Mongoose `ObjectId` references:
- Each document in the `alerts` collection maintains an optional `assetId` field referencing the parent asset's `_id` in the `assets` collection, alongside a denormalized `assetName` string to optimize query performance without requiring expensive `$lookup` aggregation joins.
- Each document in the `histories` collection similarly references `assetId` while storing independent spatial coordinates, ensuring historical audit trails remain immutable even if the parent asset's attributes are modified.

---

## 6.6 GPS AND BLE MODULE DESIGN
The dual-sensor module architecture combines wide-area satellite geolocation with local-area radio proximity sensing, as depicted in Figure 6.3.

```
+---------------------------------------------------------------------------------------------------+
|                        GPS AND BLE DUAL-SENSOR MODULE ARCHITECTURE                                |
+---------------------------------------------------------------------------------------------------+

 +-------------------------------------+       +-------------------------------------+
 |             GPS MODULE              |       |             BLE MODULE              |
 |         (geolocator package)        |       |      (flutter_blue_plus package)    |
 +-------------------------------------+       +-------------------------------------+
 | - Acquire GNSS Satellite Signals    |       | - Scan 2.4 GHz ISM Radio Spectrum   |
 | - Extract Lat/Lon WGS-84 Coordinates|       | - Intercept Peripheral Advertisements|
 | - Measure Speed, Altitude & Accuracy|       | - Extract Hardware MAC & Local Name |
 | - Reverse Geocode Address Strings   |       | - Read Raw Signal Strength (RSSI)   |
 +-------------------------------------+       +-------------------------------------+
                   |                                              |
                   | Latitude & Longitude                         | Raw RSSI (dBm)
                   v                                              v
 +-----------------------------------------------------------------------------------+
 |                             SENSOR FUSION & LOGIC ENGINE                          |
 |                                                                                   |
 |   +------------------------------------+   +----------------------------------+   |
 |   |        GEOFENCING PROCESSOR        |   |      PROXIMITY CLASSIFIER        |   |
 |   | - Retrieve Asset Safe Centroid     |   | - Apply Log-Distance Model       |   |
 |   | - Calculate Haversine Distance (d) |   | - Map to Discrete Proximity Tier:|   |
 |   | - Compare Against Radius (r_safe)  |   |   * Immediate (>= -60 dBm)       |   |
 |   | - Trigger Perimeter Breach Alert   |   |   * Near (-61 to -75 dBm)        |   |
 |   |   if d > r_safe                    |   |   * Far (-76 to -85 dBm)         |   |
 |   |                                    |   |   * Lost / Disconnected (< -85)  |   |
 |   +------------------------------------+   +----------------------------------+   |
 +-----------------------------------------------------------------------------------+
                                           |
                                           v
 +-----------------------------------------------------------------------------------+
 |                              SECURITY ALERT DISPATCHER                            |
 |  - Check 60-Second De-Duplication Window                                          |
 |  - Trigger Mobile Visual Notifications & UI Badges                                |
 |  - Dispatch Asynchronous JSON Payload to Backend API (/api/alerts)                |
 +-----------------------------------------------------------------------------------+
```
*Figure 6.3: GPS and BLE Dual-Sensor Module Integration Architecture*

---

## 6.7 DATA FLOW DESIGN (DFD LEVEL 0, 1, 2)
Data Flow Diagrams visually delineate how information enters the system, undergoes computational transformation, interacts with persistent storage, and produces user outputs.

### 6.7.1 DFD Level 0 – Context Diagram
The Level 0 Context Diagram depicts the entire system as a singular process interacting with external entities.

```
       +-----------------------+                         +----------------------+
       |                       |--- Asset Parameters --->|                      |
       |                       |<-- Visual Alerts -------|                      |
       |         USER          |<-- Inventory Details ---|                      |
       |      (Custodian)      |                         |                      |
       |                       |                         |                      |
       +-----------------------+                         |                      |
                                                         |     SMART ASSET      |
       +-----------------------+                         |      PROTECTION      |
       |     GPS SATELLITES    |--- Satellite Signals -->|         AND          |
       |       (GNSS Fix)      |                         |    HIDDEN TRACKING   |
       +-----------------------+                         |        SYSTEM        |
                                                         |      (Process 0)     |
       +-----------------------+                         |                      |
       |      BLE TRACKING     |--- Radio Adv Frames --->|                      |
       |      PERIPHERAL       |    (Payload & RSSI)     |                      |
       +-----------------------+                         |                      |
                                                         |                      |
       +-----------------------+                         |                      |
       |     MONGODB CLOUD     |<-- CRUD Transactions ---|                      |
       |        STORAGE        |--- Document Queries --->|                      |
       +-----------------------+                         +----------------------+
```
*Figure 6.4: Data Flow Diagram (DFD) Level 0 – Context Diagram*

### 6.7.2 DFD Level 1 – Subsystem Decomposition
The Level 1 DFD decomposes Process 0 into its primary functional subsystems.

```
                +-------------------+
                |       USER        |
                +-------------------+
                  |               ^
                  | Asset Input   | Display Data & Alerts
                  v               |
        +-----------------------------------+
        |  1.0 ASSET INVENTORY MANAGEMENT   |====== [ D1: Assets Store ]
        +-----------------------------------+               |
                          |                                 |
                          | Asset Safe Zone Centroids       |
                          v                                 |
  +--------+    +-----------------------------------+       |
  | GPS Rx |--->|   2.0 GPS LOCATION & GEOFENCING   |       |
  +--------+    +-----------------------------------+       |
                          |                                 |
                          | Geofence Breach Flag            |
                          v                                 |
  +--------+    +-----------------------------------+       |
  | BLE Rx |--->|   3.0 BLE SCANNING & PROXIMITY    |       |
  +--------+    +-----------------------------------+       |
                          |                                 |
                          | Disconnection / Weak RSSI Flag  |
                          v                                 |
                +-----------------------------------+       |
                |    4.0 SECURITY ALERT ENGINE      |<------+
                +-----------------------------------+
                  |                               |
                  v                               v
        [ D2: Alerts Store ]            [ D3: History Store ]
```
*Figure 6.5: Data Flow Diagram (DFD) Level 1 – Subsystem Data Transformations*

### 6.7.3 DFD Level 2 – Geofencing & Alert Processing Pipeline
The Level 2 DFD details the internal computational mechanics of the alert engine.

```
  [ GPS Latitude / Longitude ]       [ Safe Centroid & Radius from D1 ]
               |                                     |
               +------------------+------------------+
                                  |
                                  v
                   +------------------------------+
                   |  2.1 Compute Haversine Dist  |
                   +------------------------------+
                                  |
                                  v Distance (d)
                   +------------------------------+
                   | 2.2 Compare: d > r_safe?     |
                   +------------------------------+
                       /                      \
               YES    /                        \   NO
                     v                          v
       +---------------------------+    +-----------------------+
       | Generate Geofence Breach  |    | Nominal Inside Status |
       | Event (Severity: High)    |    +-----------------------+
       +---------------------------+
                     |
                     v
       +---------------------------+
       | 4.1 Check 60s History     | <==== Query [ D2: Alerts Store ]
       +---------------------------+
           /                   \
   Recent /                     \ No Recent Match
         v                       v
  [ Suppress Duplicate ]  +-------------------------------+
                          | 4.2 Commit Alert to Database  | ====> [ D2: Alerts ]
                          | 4.3 Trigger Mobile UI Alert   | ====> Output to User
                          +-------------------------------+
```
*Figure 6.6: Data Flow Diagram (DFD) Level 2 – Geofence & Alert Processing*

---

## 6.8 SECURITY AND RELIABILITY CONSIDERATIONS
Operating across mobile hardware, wireless networks, and distributed cloud databases requires strict engineering standards to ensure system security and reliability:

### 6.8.1 Security Architecture
- **Runtime OS Permission Guarding:** The mobile client adheres strictly to modern Android and iOS privacy frameworks, requesting `ACCESS_FINE_LOCATION`, `BLUETOOTH_SCAN`, and `BLUETOOTH_CONNECT` permissions at runtime with clear user-facing rationale dialogs.
- **Payload Validation & Sanitization:** The Express backend validates and sanitizes all incoming JSON request bodies against Mongoose schema definitions, preventing NoSQL injection and malformed parameter attacks.
- **Stateless RESTful Design:** Backend APIs operate statelessly, allowing endpoints to be protected behind API gateways or token-based authentication mechanisms (such as JSON Web Tokens) without modifying core route logic.

### 6.8.2 Reliability and Fault Tolerance
- **Non-Blocking Database Connection Handling:** In `server.js`, MongoDB connection failures are caught gracefully, allowing the Express HTTP server to start and return informative status messages rather than crashing the Node.js process.
- **Offline Flash Resilience:** In the event of network loss, the mobile client falls back to local data cached via `shared_preferences`, maintaining continuous local BLE scanning and geofence monitoring.
- **Signal Fluctuation Protection:** The system requires multiple consecutive degraded RSSI measurements before triggering disconnection alerts, preventing false alarms caused by transient radio interference.

---

## 6.9 SUMMARY
This chapter detailed the system design and architecture of the Smart Asset Protection and Hidden Tracking System. The overarching three-tier client-server architecture was presented, followed by structural breakdowns of the Flutter frontend, the Node.js/Express backend middleware, and the MongoDB database tier. Hardware abstraction modules for GPS and BLE were formulated, followed by comprehensive Data Flow Diagrams across Level 0, Level 1, and Level 2. Finally, security, fault tolerance, and reliability protocols were established. The next chapter details the software implementation.
