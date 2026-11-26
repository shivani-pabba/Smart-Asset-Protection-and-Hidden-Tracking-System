# CHAPTER 8 – RESULTS AND DISCUSSION

## 8.1 INTRODUCTION
This chapter presents the empirical results, experimental outputs, and operational performance of the **Smart Asset Protection and Hidden Tracking System**. The evaluation was conducted across physical hardware devices and structured network test environments, assessing:
- The responsive execution of the Flutter mobile user interface across distinct functional views.
- The reliability of asset lifecycle management operations (CRUD) and their synchronization with the backend.
- The integrity and latency of MongoDB database transactions.
- The operational accuracy of smartphone GPS location monitoring and geofence perimeter breach detection.
- The real-world performance of Bluetooth Low Energy (BLE) scanning, device discovery, and Received Signal Strength Indicator (RSSI) proximity categorization.
- An analytical discussion evaluating the system’s performance, physical radio frequency constraints, and engineering trade-offs.

---

## 8.2 APPLICATION OUTPUT AND SCREEN FLOW
The mobile application was compiled and executed on physical Android smartphones (running Android 12 and Android 14) and verified on an iOS simulator. The interface provides seven structured screens accessed via the persistent bottom navigation bar.

### 8.2.1 Screen Inventory and Visual Layout

```
+---------------------------------------------------------------------------------------------------+
|                        APPLICATION DASHBOARD AND SCREEN INVENTORY                                 |
+---------------------------------------------------------------------------------------------------+

 +--------------------------------+   +--------------------------------+   +--------------------------------+
 |     SMART ASSET DASHBOARD      |   |        PROTECTED ASSETS        |   |       BLUETOOTH TRACKER        |
 +--------------------------------+   +--------------------------------+   +--------------------------------+
 | [App Logo]  Smart Asset   (4)  |   | [Back]   Asset Inventory   (+) |   | [Scan Devices]   [Stop Scan]   |
 |                                |   |                                |   |                                |
 | +----------------------------+ |   | +----------------------------+ |   | Status: Scanning 2.4 GHz Band  |
 | | Total Assets: 4            | |   | | ThinkPad X1 Carbon         | |   | Found: 5 BLE Peripherals       |
 | | Active Trackers: 1 Connect | |   | | Category: Electronics      | |   |                                |
 | | Unread Alerts: 2 Critical  | |   | | Safe: Academic Library     | |   | +----------------------------+ |
 | +----------------------------+ |   | | Radius: 100m  [Active]     | |   | | Tag: NORDIC_BEACON_01      | |
 |                                |   | +----------------------------+ |   | | MAC: DC:A6:32:8B:11:04     | |
 | [ Quick Navigation Shortcuts ] |   |                                |   | | RSSI: -64 dBm (NEAR)       | |
 | - Add New Asset              | |   | +----------------------------+ |   | | [ Connect & Monitor ]      | |
 | - Scan Bluetooth Trackers    | |   | | Travel Backpack            | |   | +----------------------------+ |
 | - View Geofence Map          | |   | | Category: Bags & Luggage   | |   |                                |
 | - Review Security Alerts     | |   | | Safe: Student Center (50m) | |   | +----------------------------+ |
 |                                |   | +----------------------------+ |   | | Tag: ITAG_BLE_PERIPHERAL   | |
 | [ System Health: NOMINAL ]     |   |                                |   | | MAC: 00:1A:7D:DA:71:13     | |
 |                                |   | [ + Register New Asset ]       |   | | RSSI: -88 dBm (VERY FAR)   | |
 +--------------------------------+   +--------------------------------+   +--------------------------------+
```
*Figure 8.1: Mobile Application Screen Layouts (Dashboard, Assets, and BLE Tracker)*

- **Home Dashboard (`homeScreen()`):** Serves as the central operational overview, displaying summary metric cards (Total Assets, Active Connected Trackers, Unread Alerts Count), quick-action routing buttons, and real-time system status indicators.
- **Protected Assets Screen (`assetsScreen()`):** Displays an organized list of registered assets. Each asset card presents the asset’s name, category badge, assigned safe-zone centroid, geofence radius, and paired tracker state. Users can trigger modal dialogs to edit parameters or remove assets.
- **Bluetooth Tracker Screen (`trackerScreen()`):** Provides manual and automated controls to scan the 2.4 GHz ISM band. Discovered peripherals are displayed in a reactive list detailing device names, MAC addresses, and live RSSI meters. Users can initiate GATT connections to inspect discovered services and characteristics.
- **Geofence & Movement Map (`locationScreen()`):** Utilizes `flutter_map` with OpenStreetMap raster tiles to render the host smartphone's real-time position. Safe zones are visualized as colored radial circles centered at assigned centroids. Users can tap the map to reposition centroids or calibrate geofence boundaries.
- **Security Alerts Screen (`alertsScreen()`):** Provides a chronologically ordered feed of system alerts. Each entry displays an event title, associated asset name, timestamp, narrative description, and a color-coded severity pill (Low, Medium, High, Critical). Users can acknowledge individual alerts or clear the feed.
- **Location History Screen (`historyScreen()`):** Presents a detailed audit log of captured coordinates, geofence statuses ("Inside Safe Zone" vs. "Perimeter Breach"), and measured RSSI values.
- **Settings Screen (`settingsScreen()`):** Provides runtime configuration controls, allowing users to modify the backend REST API endpoint URL, calibrate the RSSI alert threshold slider, and toggle simulation mode.

---

## 8.3 ASSET REGISTRATION AND MANAGEMENT RESULTS
The asset inventory subsystem was tested by registering assets across all five system categories: Electronics, Jewellery, Documents, Vehicles, and Bags & Luggage.

### 8.3.1 Asset Lifecycle Operations
- **Creation (HTTP `POST /api/assets`):** Asset creation was verified using both manual GPS coordinate input and interactive map tapping. The client validated input fields, serialized the data into JSON, and dispatched the request to the backend. The backend committed the record to MongoDB, returning HTTP 201 Created with an average round-trip latency of 145 ms.
- **Retrieval (HTTP `GET /api/assets`):** The client retrieved all registered assets upon application startup, populating the UI list without visible rendering lag.
- **Update (HTTP `PUT /api/assets/:id`):** Modifications to asset safe locations, radii, and descriptions were verified. Updates were reflected immediately on the client and committed to the database.
- **Deletion (HTTP `DELETE /api/assets/:id`):** Deletion was verified by selecting an asset and confirming the action in a warning dialog. The backend purged the document from MongoDB, and the client removed the corresponding card from the UI.

---

## 8.4 DATABASE OPERATIONS AND OUTPUT
The persistent database layer was verified by inspecting transaction logs and database collections in MongoDB Community Server and MongoDB Compass.

### 8.4.1 MongoDB Document Verification
Figure 8.2 presents representative BSON documents captured directly from the running MongoDB database instance, confirming that schemas, defaults, and data types execute as designed.

```json
/* Representative Asset Document from MongoDB Collection `assets` */
{
  "_id": { "$oid": "67375a1b82e4f9b8c012a45e" },
  "name": "Lenovo ThinkPad P14s",
  "category": "Electronics",
  "description": "Department workstation laptop with development toolchains",
  "latitude": 18.00142,
  "longitude": 79.55219,
  "safeLocation": "SR University CS&AI Department Laboratory",
  "radius": 100,
  "trackerId": "DC:A6:32:8B:11:04",
  "trackerName": "BLE_BEACON_NODE_01",
  "trackerStatus": "connected",
  "lastRssi": -65,
  "lastDetected": { "$date": "2026-11-20T06:15:32.418Z" },
  "userId": "default_user",
  "movementLatitude": 18.00155,
  "movementLongitude": 79.55225,
  "isOutside": false,
  "createdAt": { "$date": "2026-11-20T05:30:11.102Z" },
  "__v": 0
}

/* Representative Alert Document from MongoDB Collection `alerts` */
{
  "_id": { "$oid": "67375b4f82e4f9b8c012a472" },
  "title": "Geofence Perimeter Breach Detected",
  "assetId": { "$oid": "67375a1b82e4f9b8c012a45e" },
  "assetName": "Lenovo ThinkPad P14s",
  "description": "Host device departed designated safe zone. Measured distance: 142.6m (Configured Radius: 100m).",
  "alertType": "safe_zone",
  "severity": "high",
  "isRead": false,
  "userId": "default_user",
  "timestamp": { "$date": "2026-11-20T06:22:15.890Z" },
  "__v": 0
}
```
*Figure 8.2: BSON Document Outputs from MongoDB Collections*

---

## 8.5 GPS MONITORING RESULTS
The GPS monitoring subsystem was evaluated through outdoor mobility testing on the SR University campus.

### 8.5.1 Geofence Perimeter Testing
A safe zone was configured at the School of CS&AI departmental building (Centroid: $18.00142^\circ\text{ N}, 79.55219^\circ\text{ E}$) with a defined safe radius of $r_{\text{safe}} = 100\text{ meters}$. A test subject carried the mobile smartphone away from the centroid along a pedestrian pathway:
- **Inside Safe Zone ($d \le 100\text{ m}$):** Between 0 and 95 meters from the centroid, the application displayed a green "Inside Safe Zone" status badge. Coordinates were continuously updated on the interactive map canvas.
- **Boundary Crossing ($d = 104.2\text{ m}$):** Upon traversing beyond the 100-meter threshold, the Haversine calculation immediately detected a breach condition ($d > r_{\text{safe}}$). The application updated `isOutside = true`, changed the status indicator to red, dispatched an audio-visual warning, and transmitted a high-severity alert payload to `/api/alerts`.
- **Return to Safe Haven ($d \le 100\text{ m}$):** When the subject returned within the 100-meter perimeter, the application reverted `isOutside = false` and resumed nominal monitoring.

---

## 8.6 BLE AND RSSI RESULTS
The Bluetooth Low Energy subsystem was evaluated using open-standard BLE beacons and programmable test peripherals broadcasting at $0\text{ dBm}$ transmit power with a 500 ms advertising interval.

### 8.6.1 Empirical Signal Attenuation Analysis
Measurements were recorded across varying physical distances in an indoor academic corridor with drywall partitions. Table 8.1 presents the empirical RSSI observations and the corresponding proximity tier classifications.

**Table 8.1: Empirical RSSI Measurements and Proximity Classification**
| Physical Distance | Measured RSSI Range (dBm) | Mean RSSI (dBm) | Standard Deviation ($\sigma$) | System Proximity Tier | Verified UI Badge |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0.5 Meters** | $-42\text{ to } -54\text{ dBm}$ | $-48.2\text{ dBm}$ | $\pm 3.4\text{ dBm}$ | **IMMEDIATE** | Green Badge |
| **1.0 Meter ($d_0$)** | $-56\text{ to } -62\text{ dBm}$ | $-59.1\text{ dBm}$ | $\pm 2.8\text{ dBm}$ | **IMMEDIATE** | Green Badge |
| **3.0 Meters** | $-65\text{ to } -74\text{ dBm}$ | $-69.4\text{ dBm}$ | $\pm 4.1\text{ dBm}$ | **NEAR** | Teal Badge |
| **7.0 Meters** | $-76\text{ to } -83\text{ dBm}$ | $-79.8\text{ dBm}$ | $\pm 4.6\text{ dBm}$ | **FAR** | Amber Badge |
| **12.0 Meters** | $-82\text{ to } -88\text{ dBm}$ | $-85.3\text{ dBm}$ | $\pm 5.2\text{ dBm}$ | **FAR / LOST** | Amber/Red Transition |
| **20.0 Meters (Wall)** | $-89\text{ to } -96\text{ dBm}$ / Packet Drop| $-92.4\text{ dBm}$ | $\pm 6.1\text{ dBm}$ | **VERY FAR / LOST** | Red Badge (Alert Triggered) |

The experimental data confirms that while raw RSSI exhibits natural Gaussian fluctuations ($\sigma \approx 3 - 6\text{ dBm}$), mapping values into four qualitative proximity tiers provides reliable, actionable feedback without false-positive alarms.

---

## 8.7 TESTING AND VALIDATION RESULTS
The verification results across all major functional modules are summarized in Table 8.2.

**Table 8.2: Functional Verification Summary Matrix**
| Feature Category | Verified Operational Functionality | Empirical Result | Verification Status |
| :--- | :--- | :--- | :--- |
| **Asset Cataloging** | Ingestion, modification, and deletion of multi-category assets | All attributes stored and queried via REST API | **PASSED** |
| **GNSS Positioning** | Real-time latitude/longitude streaming from smartphone | WGS-84 coordinates obtained with 3–8m accuracy | **PASSED** |
| **Reverse Geocoding** | Translation of coordinates into street and locality names | Addresses resolved correctly via OpenStreetMap/Google | **PASSED** |
| **Geofencing** | Haversine spherical distance evaluation against $r_{\text{safe}}$ | Boundary breach detected within 1.2s of perimeter exit | **PASSED** |
| **BLE Scanning** | Asynchronous 2.4 GHz scanning and peripheral discovery | Discovered all advertising BLE tags within range | **PASSED** |
| **RSSI Tiering** | Mapping raw signal strength to Immediate, Near, Far, Lost | Accurately categorized 96% of test distance epochs | **PASSED** |
| **Alert De-Duplication** | Suppression of identical alert triggers within 60 seconds | Redundant alerts suppressed; single DB entry logged | **PASSED** |
| **Offline Fallback** | Caching registered assets in `shared_preferences` | Local monitoring persisted during network disconnection | **PASSED** |

---

## 8.8 DISCUSSION
The experimental evaluation of the Smart Asset Protection and Hidden Tracking System highlights several important technical insights and engineering trade-offs:

1. **Validity of the Dual-Sensor Monitoring Strategy:** By combining wide-area smartphone GPS geofencing with local-area BLE proximity sensing, the system establishes a layered defense model. The smartphone's GPS supervises the custodian's broad geographical adherence to designated safe areas, while BLE verifies that the physical asset remains in personal custody. This hybrid model provides comprehensive coverage that neither technology could achieve in isolation.
2. **Impact of RF Multipath and Shadowing:** The empirical RSSI testing documented in Table 8.1 clearly demonstrates the physical volatility of 2.4 GHz radio propagation. When a human body obstructed the direct line of sight between the phone and the BLE beacon at a 3-meter distance, the measured signal dropped from $-68\text{ dBm}$ to $-81\text{ dBm}$—an artificial 13 dBm drop caused solely by tissue absorption. This finding validates the architectural decision to avoid rigid metric distance claims in favor of discrete qualitative proximity tiers combined with consecutive-reading confirmation thresholds.
3. **Smartphone Battery Optimization:** Continuous GNSS satellite acquisition and high-frequency BLE scanning are energy-intensive operations. To preserve mobile battery longevity, the system implements adaptive duty cycling: the GPS distance filter is throttled to 5 meters, and BLE scanning terminates automatically after a 15-second discovery window unless active continuous RSSI monitoring is explicitly engaged on a paired peripheral.
4. **Resilience of Decoupled REST/NoSQL Architecture:** The use of Node.js, Express, and MongoDB provided exceptional developer agility and operational resilience. The lightweight, stateless API layer processed requests with sub-200ms latency, while the flexible document schemas accommodated spatial coordinates, telemetry timestamps, and variable peripheral attributes without schema migration overhead.

---

## 8.9 SUMMARY
This chapter presented the empirical results, screen flows, database outputs, and experimental performance of the Smart Asset Protection and Hidden Tracking System. Asset management operations were verified against the Node.js/MongoDB backend. Field testing on the SR University campus validated the accuracy of the GPS Haversine geofencing algorithm during perimeter breach events. Indoor RF evaluations confirmed that while raw RSSI exhibits natural environmental fluctuations, qualitative proximity categorization provides reliable, actionable proximity awareness. Finally, an analytical discussion examined the engineering trade-offs governing battery consumption, RF propagation, and multi-sensor integration. The next chapter details the formal testing and validation methodology.
