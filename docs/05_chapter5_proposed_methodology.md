# CHAPTER 5 – PROPOSED METHODOLOGY

## 5.1 INTRODUCTION
The methodology of the **Smart Asset Protection and Hidden Tracking System** establishes a systematic, multi-tiered approach to personal property safeguarding. Protecting physical assets against loss or theft requires continuous monitoring across two fundamentally different spatial domains:
1. **The Macro-Spatial Domain (Global Coordinates):** Tracking the physical location of the asset's custodian across urban, suburban, and campus environments relative to authorized safe perimeters.
2. **The Micro-Spatial Domain (Local Proximity):** Verifying the immediate physical proximity between the custodian and the tracked item within localized indoor environments (such as rooms, desks, or vehicles).

To bridge these domains, the proposed methodology integrates cross-platform mobile computing (Flutter/Dart), satellite geolocation (smartphone GNSS), low-power radio frequency sensing (Bluetooth Low Energy), asynchronous cloud middleware (Node.js/Express), and document-based data persistence (MongoDB). 

This chapter presents the operational methodology of the system. It formulates:
- The end-to-end system workflow and operational lifecycle.
- The mathematical foundations of spherical geofencing (Haversine formula).
- The radio frequency propagation model for BLE RSSI proximity classification (Log-Distance Path Loss).
- The asset registration, tracking, alert generation, and data persistence pipelines.

---

## 5.2 SYSTEM WORKFLOW
The operational lifecycle of the system operates as a coordinated sequence of asynchronous processes. Figure 5.1 illustrates the comprehensive methodology flowchart.

```
+---------------------------------------------------------------------------------------------------+
|                        COMPREHENSIVE FLOWCHART OF PROPOSED METHODOLOGY                            |
+---------------------------------------------------------------------------------------------------+

                                             [ START ]
                                                 |
                                                 v
                                  [ Initialize Mobile Client ]
                                                 |
                                                 v
                             [ Check & Request Runtime OS Permissions ]
                                   - ACCESS_FINE_LOCATION
                                   - BLUETOOTH_SCAN & CONNECT
                                                 |
                                                 v
                                  [ Authenticate / Select Profile ]
                                                 |
                                                 v
                                   [ Main Dashboard View Loaded ]
                                                 |
                 +-------------------------------+-------------------------------+
                 |                                                               |
                 v                                                               v
      [ ASSET INVENTORY MODULE ]                                    [ DUAL-SENSOR TELEMETRY ENGINE ]
                 |                                                               |
                 v                                                               v
      [ Register / Select Asset ]                                 +--------------+--------------+
      - Specify Name & Category                                   |                             |
      - Define Centroid (Lat, Lon)                                v                             v
      - Set Geofence Radius (r_safe)                    [ Smartphone GNSS Stream ]     [ Asynchronous BLE Scanner ]
                 |                                      - Fetch WGS-84 Coordinates     - Scan 2.4 GHz Channels
                 v                                      - Reverse Geocode Place Name   - Discover Peripheral MACs
      [ Send JSON to REST Backend ]                               |                             |
      - POST /api/assets                                          v                             v
                 |                                      [ Evaluate Haversine ]         [ Intercept Beacon RSSI ]
                 v                                      Calculate Distance (d)         - Immediate (>= -60 dBm)
      [ Persist in MongoDB Atlas ]                      to Safe Centroid (Lat0, Lon0)  - Near (-61 to -75 dBm)
                 |                                                |                    - Far (-76 to -85 dBm)
                 |                                                |                    - Lost / Disconnected (< -85)
                 |                                                |                             |
                 +-------------------------------+----------------+                             |
                                                 |                                              |
                                                 v                                              v
                                   [ Boundary & Proximity Check ] <-----------------------------+
                                                 |
                                                 v
                                   +---------------------------+
                                   | Is Perimeter Breached?    |
                                   | (d > r_safe)              |
                                   |         OR                |
                                   | Is BLE Tracker Disconnected/|
                                   | Degraded (RSSI < -85 dBm)?|
                                   +---------------------------+
                                          /             \
                                  YES    /               \    NO
                                        v                 v
                         [ Security Event Triggered ]   [ Nominal State Maintained ]
                                        |               - Display Healthy Badges
                                        v               - Log Coordinates in Cache
                         [ Check Temporal Deduplication ]
                         - Is matching alert < 60s old?
                                  /           \
                          YES    /             \   NO
                                v               v
                       [ Suppress Duplicate ]  [ Dispatch Alert ]
                                               - Push Local Notification
                                               - POST /api/alerts
                                               - Log in MongoDB
                                               - Render High-Severity UI Badge
                                                        |
                                                        v
                                             [ Display on Map & Logs ]
                                                        |
                                                        v
                                             [ Continue Monitoring ]
```
*Figure 5.1: Comprehensive Flowchart of Proposed System Methodology*

---

## 5.3 ASSET REGISTRATION METHOD
Asset registration establishes the baseline profile and security parameters for a physical possession. Without an explicit digital record, a physical asset cannot be associated with spatial boundaries or radio peripherals.

### Step-by-Step Registration Procedure:
1. **User Input Ingestion:** The user opens the Asset Management interface in the Flutter mobile application and taps the creation control. The UI renders a structured modal dialog requiring:
   - **Asset Name:** A clear label (e.g., "MacBook Pro", "Travel Passport", "Toolbox").
   - **Category Selection:** Categorized as *Electronics*, *Jewellery*, *Documents*, *Vehicles*, or *Bags & Luggage*.
   - **Description:** Contextual notes regarding serial numbers or physical features.
2. **Safe-Zone Centroid Assignment:** The user assigns a geographic safe location. The application provides two options:
   - *Current GPS Fix:* Uses the smartphone's real-time coordinates captured by the GNSS receiver.
   - *Manual Map Tap:* The user taps a specific location on the interactive OpenStreetMap/Google Maps canvas.
3. **Safe-Zone Radius Configuration:** The user selects a safe radius ($r_{\text{safe}}$) from predefined options: $50\text{ m}$, $100\text{ m}$, $250\text{ m}$, or $500\text{ m}$.
4. **BLE Tracker Pairing (Optional / Asynchronous):** The user can pair the asset with an active BLE peripheral discovered during Bluetooth scanning, binding the peripheral's MAC address to the asset record.
5. **Backend Dispatch and Persistence:** The mobile client serializes the asset data into a JSON payload and dispatches an asynchronous HTTP `POST` request to `/api/assets`. The Node.js backend validates the payload and commits the document to MongoDB.

---

## 5.4 GPS LOCATION MONITORING METHOD
The GPS location monitoring subsystem continuously captures the spatial coordinates of the host smartphone to supervise safe-zone compliance.

### 5.4.1 GNSS Acquisition and WGS-84 Coordinate Streaming
The mobile client utilizes the `geolocator` package to interface with the native Android LocationManager or iOS CoreLocation framework. The application establishes a continuous position stream configured with:
- **Desired Accuracy:** `LocationAccuracy.high` (utilizing multi-constellation GNSS, Wi-Fi triangulation, and cellular tower assistance).
- **Distance Filter:** 5 meters (a position update is emitted only when the host device moves at least 5 meters, conserving battery power).

Upon receiving raw geographic coordinates, the application invokes the `geocoding` plugin to perform asynchronous reverse geocoding, resolving numeric coordinates into a human-readable street address and locality name.

### 5.4.2 Mathematical Geofencing: The Haversine Formulation
To evaluate whether the host device has departed an asset's safe haven, the system calculates the great-circle spherical distance between the current smartphone position and the asset's safe centroid.

Let:
- $(\phi_1, \lambda_1)$ represent the safe-zone centroid latitude and longitude in radians.
- $(\phi_2, \lambda_2)$ represent the host smartphone's current latitude and longitude in radians.
- $R \approx 6,371,000\text{ meters}$ represent the mean radius of the Earth.

The difference in latitude and longitude coordinates is:

$$\Delta\phi = \phi_2 - \phi_1 = (\text{lat}_2 - \text{lat}_1) \times \frac{\pi}{180}$$

$$\Delta\lambda = \lambda_2 - \lambda_1 = (\text{lon}_2 - \text{lon}_1) \times \frac{\pi}{180}$$

The square of half the chord length between the two points on a unit sphere ($a$) is computed using the Haversine formula:

$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1) \cdot \cos(\phi_2) \cdot \sin^2\left(\frac{\Delta\lambda}{2}\right)$$

The angular distance in radians ($c$) is:

$$c = 2 \cdot \arctan2\left(\sqrt{a}, \sqrt{1 - a}\right)$$

The great-circle surface distance $d$ in meters is:

$$d = R \cdot c$$

```
                          North Pole
                              *
                             / \
                            /   \
                           /     \
                          /       \
                         /  d = R*c\
                        o-----------o  Smartphone Position (lat2, lon2)
                       /             \
                      /   r_safe      \
                     /  (Safe Zone)    \
   Safe Centroid    o-------------------o
   (lat1, lon1)    /                     \
                  *                       *
```
*Figure 5.3: Spherical Haversine Geofence Boundary Check Principle*

### 5.4.3 Perimeter Evaluation Logic
The calculated distance $d$ is evaluated against the asset's defined geofence radius $r_{\text{safe}}$:

$$\text{Condition} = \begin{cases} d \le r_{\text{safe}} \implies \text{INSIDE SAFE ZONE (Nominal)} \\ d > r_{\text{safe}} \implies \text{OUTSIDE SAFE ZONE (Perimeter Breach Alert)} \end{cases}$$

When $d > r_{\text{safe}}$, the system sets `isOutside = true` and dispatches a geofence breach security event to the alert pipeline.

---

## 5.5 BLUETOOTH LOW ENERGY TRACKING METHOD
While GPS geofencing monitors wide-area spatial boundaries, Bluetooth Low Energy (BLE) governs immediate physical custody.

### 5.5.1 Asynchronous BLE Scanning Protocol
The BLE subsystem operates via the `flutter_blue_plus` package:
1. **Adapter Validation:** The application verifies that the host smartphone's Bluetooth radio is powered on and that `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` permissions are granted.
2. **Asynchronous Scan Initiation:** The application calls `FlutterBluePlus.startScan()`, listening across standard 2.4 GHz advertising channels (Channels 37, 38, 39).
3. **Advertising Frame Interception:** When an advertising frame is received, the system extracts:
   - Remote Hardware Identifier (MAC Address / Device UUID).
   - Advertised Local Name.
   - Received Signal Strength Indicator (RSSI in dBm).
   - Timestamp of packet arrival.

```
+-----------------------------------------------------------------------------------------+
|                  BLE ADVERTISING, SCANNING, AND RSSI CAPTURE TIMELINE                   |
+-----------------------------------------------------------------------------------------+

  [ BLE Peripheral / Tag ]                       [ Smartphone Host / Central ]
             |                                                  |
             |-------- ADV_IND (Ch 37, 38, 39) ---------------->|  Packet Intercepted
             |         (Payload, MAC, Tx Power)                 |  Measure Carrier RSSI
             |                                                  |  (e.g., -68 dBm)
             |                                                  |
             |                                                  |--+ Apply Log-Distance
             |                                                  |  | Proximity Model
             |                                                  |<-+ (Category: NEAR)
             |                                                  |
             |<------- Optional Connection Request ------------|  (If GATT Connectable)
             |-------- Connection Handshake Acknowledged ------>|
             |                                                  |
             |<------- Read Remote RSSI (Periodic Timer) ------|  Continuous Link Check
             |-------- Return RSSI dBm Value ------------------>|  (Every 2.0 Seconds)
```
*Figure 5.2: BLE Advertising, Scanning, and Connection Protocol Sequence*

### 5.5.2 Proximity Categorization via Log-Distance Attenuation
As established in Chapter 2, raw RSSI is modeled by the Log-Distance Path Loss equation:

$$\text{RSSI}(d) = \text{RSSI}(d_0) - 10 \cdot n \cdot \log_{10}\left(\frac{d}{d_0}\right) + X_\sigma$$

Rather than presenting noisy, fluctuating metric distances that mislead users, the system maps raw RSSI into discrete, actionable proximity tiers. Table 5.1 outlines these qualitative thresholds.

**Table 5.1: Qualitative RSSI Proximity Categorization Thresholds**
| Measured RSSI Range | Qualitative Proximity Tier | Estimated Physical Range | Recommended Action / UI State |
| :--- | :--- | :--- | :--- |
| $\text{RSSI} \ge -60\text{ dBm}$ | **IMMEDIATE** | $< 1.5\text{ meters}$ | Optimal custody (Green badge). Asset is within arm's reach. |
| $-75\text{ dBm} \le \text{RSSI} < -60\text{ dBm}$| **NEAR** | $1.5 - 5.0\text{ meters}$ | Normal proximity (Teal badge). Asset is in the same room. |
| $-85\text{ dBm} \le \text{RSSI} < -75\text{ dBm}$| **FAR** | $5.0 - 15.0\text{ meters}$ | Attenuated signal (Amber badge). Separation boundary approaching. |
| $\text{RSSI} < -85\text{ dBm}$ or Timeout | **VERY FAR / LOST** | $> 15.0\text{ meters}$ or Obstructed | Signal critical (Red badge). Trigger disconnection alert. |

---

## 5.6 GEOFENCING AND ALERT PROCESSING PIPELINE
The alert processing pipeline operates as an event-driven engine, synthesizing spatial coordinates from the GPS module and signal strength metrics from the BLE module.

### 5.6.1 Alert Trigger Conditions
Security alerts are triggered under four distinct operational scenarios:
1. **Safe-Zone Perimeter Breach (`safe_zone`):** The calculated Haversine distance $d$ between the smartphone and the asset's safe-zone centroid exceeds the defined radius $r_{\text{safe}}$.
2. **BLE Tracker Disconnection (`tracker_disconnected`):** An active BLE peripheral connection drops or fails to advertise for longer than a specified timeout window.
3. **Critical RSSI Attenuation (`weak_rssi`):** The measured RSSI remains below a configurable alert threshold (e.g., $-80\text{ dBm}$) for multiple consecutive polling cycles.
4. **General System Warning (`system`):** Operating system permissions are revoked or location services are disabled by the user.

### 5.6.2 Temporal Alert De-Duplication Pipeline
To prevent alert fatigue and database flooding caused by boundary oscillations or intermittent radio fading, the backend implements an automated temporal deduplication filter.

Let an incoming alert event be characterized by tuple $E = (\text{title}, \text{assetName}, t_{\text{current}})$.

The backend queries the `Alert` collection for existing records matching:

$$\text{Filter} = \begin{cases} \text{title} = E.\text{title} \\ \text{assetName} = E.\text{assetName} \\ \text{timestamp} \ge (t_{\text{current}} - 60\text{ seconds}) \end{cases}$$

- If a matching document exists: The server suppresses creation, returning HTTP 200 with message `"Duplicate alert suppressed"`.
- If no matching document exists: The server commits the alert document to MongoDB and returns HTTP 201 Created.

---

## 5.7 DATA STORAGE AND MANAGEMENT METHOD
The system implements a hybrid data management strategy balancing centralized cloud persistence with local offline resilience:

### 5.7.1 RESTful Web Service Communication
All persistent state operations occur over standard HTTP JSON endpoints:
- Asset CRUD: Handled via `GET`, `POST`, `PUT`, `DELETE` at `/api/assets`.
- Tracker Updates: Lightweight status synchronizations dispatched via `PATCH /api/assets/:id/tracker`.
- Security Event Ingestion: Dispatched via `POST /api/alerts`.
- Spatial History Logging: Transmitted via `POST /api/history`.

### 5.7.2 Offline Fallback Mechanism via SharedPreferences
If the mobile client experiences network disconnection (e.g., cellular data drop or Wi-Fi unavailability), it automatically activates an offline fallback mechanism using `shared_preferences`:
1. Registered asset definitions and safe centroids are serialized to local device flash storage upon successful retrieval.
2. If an API request to the backend fails with a socket or network timeout, the client falls back to locally cached asset data, allowing continuous BLE proximity scanning and GPS geofence checks.
3. Unsynchronized events are held in memory and retried when network connectivity is re-established.

---

## 5.8 SUMMARY
This chapter formulated the complete proposed methodology for the Smart Asset Protection and Hidden Tracking System. The end-to-end operational workflow was defined and illustrated via a comprehensive flowchart. Mathematical derivations were provided for both the Haversine spherical distance formula (used for geofencing) and the Log-Distance Path Loss model (used for BLE RSSI proximity classification). The asset registration lifecycle, GPS monitoring pipeline, asynchronous BLE scanning procedure, and 60-second temporal alert deduplication filter were detailed. Finally, the hybrid cloud-local data persistence strategy was outlined. The next chapter presents the system design and architecture.
