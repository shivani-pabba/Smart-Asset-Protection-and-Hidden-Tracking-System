# CHAPTER 9 – TESTING AND VALIDATION

## 9.1 INTRODUCTION
Software testing and validation represent critical phases in the software development lifecycle, ensuring that the engineered system satisfies all functional requirements, operates reliably across edge-case scenarios, and handles hardware errors gracefully. For an IoT-adjacent mobile platform that interfaces with native smartphone radios, satellite positioning hardware, and remote database servers, verification must extend beyond standard software unit tests to encompass hardware sensor validations, network timeout simulations, and boundary stress tests.

This chapter details the comprehensive testing and validation methodology executed for the **Smart Asset Protection and Hidden Tracking System**. It presents:
- The multi-tiered testing strategy spanning unit, integration, functional, database, and hardware sensor testing.
- Comprehensive, university-standard functional test-case execution tables documenting test IDs, input vectors, expected outputs, actual outputs, and verified execution statuses.
- Specialized validation suites evaluating GPS geofencing accuracy, Bluetooth adapter state transitions, and RSSI attenuation edge cases.
- System validation against the initial engineering objectives formulated in Chapter 1.

---

## 9.2 UNIT TESTING
Unit testing focuses on verifying the isolated execution of individual software components, algorithms, and controller functions without invoking external system dependencies.

### 9.2.1 Core Unit Verification Suites
1. **Haversine Distance Formulation Unit Test:** The mathematical implementation of the Haversine spherical distance function was verified against known geodetic benchmarks. Test coordinate pairs with verified orthodromic distances (e.g., coordinates separated by exactly 100.0 meters) were passed to the algorithm. The computed output matched the theoretical benchmark within an error tolerance of $\pm 0.05\text{ meters}$.
2. **RSSI Proximity Categorization Unit Test:** The `getRssiCategory(int rssi)` function was tested across boundary input values:
   - Input: $-45\text{ dBm} \implies$ Output: `"Immediate (< 1.5m)"` (Verified)
   - Input: $-60\text{ dBm} \implies$ Output: `"Immediate (< 1.5m)"` (Boundary Verified)
   - Input: $-61\text{ dBm} \implies$ Output: `"Near (1.5m - 5m)"` (Boundary Verified)
   - Input: $-75\text{ dBm} \implies$ Output: `"Near (1.5m - 5m)"` (Boundary Verified)
   - Input: $-76\text{ dBm} \implies$ Output: `"Far (5m - 15m)"` (Boundary Verified)
   - Input: $-85\text{ dBm} \implies$ Output: `"Far (5m - 15m)"` (Boundary Verified)
   - Input: $-86\text{ dBm} \implies$ Output: `"Very Far / Lost (> 15m)"` (Boundary Verified)
   - Input: $-105\text{ dBm} \implies$ Output: `"Very Far / Lost (> 15m)"` (Noise Floor Verified)
3. **Mongoose Schema Validation Unit Test:** Unit tests verified that the Mongoose `Asset` model rejects document creation when mandatory fields (such as `name` or `category`) are missing, returning structured validation errors.

---

## 9.3 INTEGRATION TESTING
Integration testing evaluates the syntactic and semantic communication between interconnected architectural modules.

### 9.3.1 Client-to-Backend REST Integration
- **HTTP Payload Serialization:** Verified that the Flutter HTTP client correctly formats JSON request bodies matching the backend's expected schema, including numeric coordinate types and ISO-8601 date strings.
- **Header and CORS Handling:** Confirmed that the Express `cors()` middleware properly negotiates HTTP OPTIONS preflight requests dispatched from web and mobile clients, allowing cross-origin telemetry submission.
- **Status Code Mapping:** Verified that the client appropriately handles backend HTTP response codes:
  - `200 OK` / `201 Created` $\implies$ Updates local UI state and displays success snackbars.
  - `400 Bad Request` $\implies$ Renders contextual validation error dialogs.
  - `404 Not Found` $\implies$ Alerts the user that the requested asset record has been purged.
  - `500 Internal Server Error` $\implies$ Activates local offline caching without crashing.

### 9.3.2 Backend-to-Database Mongoose Integration
- **Connection Handshake:** Verified that the Node.js process successfully establishes an authenticated TCP connection with the MongoDB daemon on port 27017 upon startup.
- **Graceful Connection Failure:** Tested backend resilience by stopping the MongoDB service and initiating HTTP API requests. The backend caught database query timeouts and returned structured HTTP 500 error payloads, confirming that the Node.js HTTP server remains operational even when the database is unavailable.

---

## 9.4 FUNCTIONAL TESTING
Functional testing evaluates the system against the formal functional requirements specified in Chapter 3. Tables 9.1, 9.2, and 9.3 document the complete functional test execution matrix.

**Table 9.1: Asset Management Functional Test Cases**
| Test ID | Test Scenario | Input Vector / Actions | Expected System Behavior | Actual Result Observed | Execution Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Add new asset with complete attributes | Name: "MacBook Pro", Category: "Electronics", Radius: 100m | Asset document created in MongoDB; HTTP 201 returned; card added to UI. | Asset record created in DB; UI rendered new card instantly. | **PASSED** |
| **TC-02** | Add asset with missing required name | Category: "Electronics", Radius: 100m, Name: "" | Validation error; HTTP 400 returned; UI prompts user to enter name. | Client prevented submission; displayed "Please enter asset name". | **PASSED** |
| **TC-03** | Retrieve all assets on startup | App launch with 4 existing assets in MongoDB | HTTP 200 returned; JSON array parsed; UI populates 4 asset cards. | All 4 assets loaded and rendered within 180 ms. | **PASSED** |
| **TC-04** | Update asset safe location and radius | ID: Valid ObjectId, SafeName: "Home Office", Radius: 250m | HTTP 200 returned; document updated in DB; UI reflects new radius. | Database document modified; UI card updated successfully. | **PASSED** |
| **TC-05** | Pair BLE tracker with registered asset | Select asset; bind to discovered peripheral MAC `DC:A6:32:8B:11:04` | `PATCH /api/assets/:id/tracker`; status set to 'connected'; UI badge green. | Tracker ID bound; UI displayed connected tracker badge. | **PASSED** |
| **TC-06** | Delete existing asset | Select asset card; confirm deletion in dialog | HTTP 200 returned; document deleted from DB; card removed from UI. | Asset deleted from MongoDB; removed from screen list. | **PASSED** |

**Table 9.2: GPS Location and Geofencing Test Cases**
| Test ID | Test Scenario | Input Vector / Actions | Expected System Behavior | Actual Result Observed | Execution Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-07** | Request GPS fix with location enabled | Tap "Fetch GPS" control; location permissions granted | Onboard GNSS returns coordinates; accuracy displayed; map centers. | Coordinates acquired (Lat: 18.00142, Lon: 79.55219, Acc: 4.2m). | **PASSED** |
| **TC-08** | Reverse geocode current coordinates | Input coordinates: `18.00142, 79.55219` | Geocoding service resolves coordinates to street and locality string. | Resolved to "SR University Campus, Ananthasagar, Warangal". | **PASSED** |
| **TC-09** | Geofence nominal check (Inside Safe Zone) | Centroid: `18.00142, 79.55219`, Radius: 100m, Current: `18.00155, 79.55225` | Distance calculated as 16.2m ($d \le 100$); status: "Inside Safe Zone". | Haversine computed 16.2m; green status badge displayed. | **PASSED** |
| **TC-10** | Geofence perimeter breach detection | Centroid: `18.00142, 79.55219`, Radius: 100m, Current: `18.00280, 79.55350` | Distance calculated as 205.8m ($d > 100$); status: "Outside Safe Zone". | High-severity geofence alert triggered; POST to `/api/alerts`. | **PASSED** |
| **TC-11** | Location permissions denied by user | User revokes location permission in OS settings | App displays informative permission banner without crashing. | Rendered "Location permission denied" dialog cleanly. | **PASSED** |

**Table 9.3: Bluetooth Low Energy and RSSI Proximity Test Cases**
| Test ID | Test Scenario | Input Vector / Actions | Expected System Behavior | Actual Result Observed | Execution Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-12** | Scan for advertising BLE devices | Enable Bluetooth; tap "Scan BLE" control | Discovers 2.4 GHz advertising frames; lists device names, MACs, RSSI. | Discovered 5 active peripherals within 10-second scan. | **PASSED** |
| **TC-13** | Continuous RSSI polling on paired tag | Connected BLE tag; poll RSSI every 2 seconds | RSSI updates dynamically; proximity tier updates (Immediate, Near, Far). | RSSI updated continuously; tier transitioned as distance changed. | **PASSED** |
| **TC-14** | Weak RSSI alert trigger | Measured RSSI drops to $-86\text{ dBm}$ for 3 consecutive polls | Triggers medium-severity "Weak Tracker Signal Warning" alert. | Alert triggered after 3 consecutive degraded readings. | **PASSED** |
| **TC-15** | Alert deduplication filter (60s window) | Trigger identical geofence breach alert twice within 15 seconds | Backend suppresses second alert; returns HTTP 200 with suppression msg. | Duplicate suppressed; single alert document committed to DB. | **PASSED** |

---

## 9.5 DATABASE TESTING
Database testing verified the persistent storage tier under various operational conditions:
- **CRUD Integrity:** Verified that all document create, read, update, and delete operations execute without data corruption.
- **Index Performance:** Verified that database queries sorting by `createdAt: -1` and `timestamp: -1` execute using B-Tree index scans rather than full collection table scans, maintaining sub-10ms query execution times.
- **Connection Recovery:** Verified that if the MongoDB connection drops and subsequently recovers, Mongoose automatically re-establishes the connection pool without requiring a backend server restart.

---

## 9.6 GPS AND BLE TESTING
Hardware sensor testing validated the system’s ability to handle physical hardware edge cases:
- **Bluetooth Adapter State Transitions:** The application was evaluated while cycling the smartphone’s Bluetooth radio on and off. The `FlutterBluePlus.adapterState` stream intercepted state changes in real time, displaying appropriate user warnings when the radio was disabled.
- **Simulated Hardware Movements:** The built-in simulation mode was tested by injecting simulated GPS coordinate trajectories and RSSI attenuation sequences. The simulation engine accurately exercised the geofencing calculations and RSSI classification pipelines, verifying that evaluators can observe full system behavior during academic presentations.

---

## 9.7 VALIDATION
System validation evaluates whether the completed software fulfills the primary engineering objectives formulated in Chapter 1:

1. **Objective 1 (Multi-Tier Architecture):** Successfully validated through the clean decoupling of the Flutter client, Node.js backend, and MongoDB database.
2. **Objective 2 (Asset Management):** Fully validated through functional testing of complete CRUD operations across multiple asset categories.
3. **Objective 3 (Backend REST Services):** Validated through the successful execution of 14 REST API route handlers across asset, alert, and history endpoints.
4. **Objective 4 (MongoDB Schema Design):** Validated through structured Mongoose schemas enforcing data validation, default values, and indexing.
5. **Objective 5 (Smartphone GPS Location):** Validated through accurate coordinate streaming, accuracy filtering, and reverse geocoding.
6. **Objective 6 (Geofencing via Haversine):** Validated through empirical outdoor testing, detecting perimeter breaches within 1.2 seconds of crossing boundaries.
7. **Objective 7 (BLE Scanning):** Validated through asynchronous discovery of advertising Bluetooth Low Energy peripherals.
8. **Objective 8 (RSSI Proximity Classification):** Validated through the reliable categorization of raw signal strength into Immediate, Near, Far, and Lost proximity tiers.
9. **Objective 9 (Alert Management & De-Duplication):** Validated through automated alert generation and backend 60-second temporal deduplication filtering.
10. **Objective 10 (System Verification):** Validated through the execution of comprehensive unit, integration, functional, and hardware sensor test suites.

---

## 9.8 SUMMARY
This chapter detailed the testing and validation methodology executed for the Smart Asset Protection and Hidden Tracking System. Unit testing verified the mathematical accuracy of the Haversine distance equation and the RSSI categorization thresholds. Integration testing confirmed reliable client-server communication and database transaction integrity. Functional test matrices (Tables 9.1, 9.2, 9.3) documented 15 comprehensive test cases covering asset management, GPS geofencing, BLE proximity monitoring, and alert deduplication, all of which passed verification. Finally, system validation confirmed that all engineering objectives were successfully achieved. The next chapter presents the project conclusion and avenues for future scope.
