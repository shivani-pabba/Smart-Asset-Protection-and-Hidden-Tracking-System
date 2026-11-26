# CHAPTER 3 – REQUIREMENT AND SYSTEM ANALYSIS

## 3.1 EXISTING SYSTEM OVERVIEW
Traditional methods of asset tracking and personal property management have predominantly relied on manual, mechanical, or single-technology approaches. Within institutional and enterprise environments, asset management typically relies on static spreadsheets, paper-based equipment checkout logs, or visual barcode labeling. In personal domains, individuals rely on memory, physical keys, or proprietary tracking tags.

Existing systems can be categorized into four primary paradigms:
1. **Manual and Visual Inventory Management:** Equipment is assigned an alphanumeric identifier and inscribed in an inventory registry. Auditing requires physical inspections by personnel armed with handheld clipboards or optical barcode scanners.
2. **Dedicated Satellite-Cellular Asset Trackers:** High-value logistics containers and fleet vehicles are equipped with active GPS transponders powered by internal batteries and paired with cellular modems. These units periodically transmit latitude and longitude coordinates to proprietary web portals.
3. **Stand-Alone Consumer Bluetooth Beacons:** Consumer tracking accessories (such as Tile or first-generation Bluetooth tags) interface with proprietary mobile applications over point-to-point Bluetooth links.
4. **Platform-Exclusive Crowdsourced Tracking Networks:** Proprietary tracking ecosystems (such as Apple’s Find My network or Samsung’s SmartThings Find) utilize proprietary cryptographic protocols to leverage surrounding consumer smartphones as crowdsourced relay nodes.

While each of these paradigms serves specific operational niches, they fail to provide an accessible, transparent, cross-platform framework suitable for customized personal asset protection and educational/enterprise deployment.

---

## 3.2 LIMITATIONS OF EXISTING SYSTEMS
A critical analysis of existing asset management systems reveals numerous structural, technical, and operational limitations:

1. **Fragmentation of Functionality:** Existing tracking solutions require multiple disparate applications. A user must navigate one application to view stationary inventory logs, a second application to interact with a specific brand of Bluetooth tag, and a third mapping tool to observe smartphone location.
2. **High Deployment and Maintenance Costs:** Standalone GPS trackers require dedicated hardware costing upwards of $50 to $200 per unit, combined with recurring monthly cellular SIM subscription fees ($5 to $20 per device per month). This makes tracking everyday personal items cost-prohibitive.
3. **Severe Battery Life Constraints:** Active cellular GPS tracking hardware consumes substantial current (typically 50–150 mA during active satellite acquisition and cellular transmission). Consequently, units require recharging every few days, creating a critical vulnerability when batteries deplete unnoticed.
4. **Inability to Function in Indoor Environments:** Satellite signals suffer massive attenuation when passing through building roofs, reinforced concrete slabs, and metallic window coatings. As a result, standalone GPS trackers fail completely inside academic buildings, libraries, and homes—the precise locations where personal assets are most frequently misplaced.
5. **Proprietary Vendor Lock-In:** Leading consumer tracking tags (e.g., Apple AirTag) enforce rigid operating system exclusivity. An Android user cannot pair, configure, or directly monitor an Apple AirTag. Furthermore, these proprietary platforms do not expose open REST APIs, preventing integration with institutional inventory databases.
6. **False-Positive Proximity Alarms:** Primitive Bluetooth tracking tags trigger abrupt disconnection sirens whenever temporary radio interference or physical line-of-sight obstruction occurs. This lack of signal smoothing leads users to disable alert mechanisms entirely.
7. **Technological Misconceptions Regarding Smartphone GPS:** Users and ill-conceived applications frequently assume that a smartphone's GPS can locate an independent, detached item. Without a paired radio peripheral, a smartphone can only track its own location.

---

## 3.3 PROPOSED SYSTEM ARCHITECTURE
The proposed **Smart Asset Protection and Hidden Tracking System** resolves these limitations by designing an integrated, multi-tier software ecosystem that unifies mobile client sensing, cloud middleware, and non-relational database persistence.

### Core Architectural Concepts:
- **Decoupled Three-Tier Architecture:** The system separates concerns across a presentation layer (Flutter client), an application logic layer (Node.js/Express REST server), and a data persistence layer (MongoDB). This decoupling ensures modularity, maintainability, and scalability.
- **Dual-Layer Sensing Engine:**
  1. *Macro-Level Monitoring (Smartphone GNSS):* Tracks the custodian's smartphone coordinates using standard location APIs. By defining virtual safe-zone centroids and radii (geofences), the system establishes geographic safe havens.
  2. *Micro-Level Monitoring (Bluetooth Low Energy):* Asynchronously scans for compatible BLE beacons attached to physical assets. By evaluating Received Signal Strength Indicator (RSSI) values, the system monitors immediate personal custody.
- **Centralized RESTful API:** A standardized HTTP REST API enables transparent data exchange between the Flutter frontend and the Node.js backend. This open architecture allows future integration with institutional databases, third-party web portals, and external analytics engines.
- **Offline-First Resilience:** In the event of cellular or Wi-Fi network disconnection, the mobile client caches registered asset metadata and continues local BLE proximity scanning and GPS geofence evaluations, ensuring that safety monitoring is not interrupted by network dropouts.
- **Transparent Academic Simulation Mode:** A built-in simulation engine allows evaluators to simulate GPS movement and RSSI attenuation dynamically during project presentations, ensuring complete transparency and reproducibility.

---

## 3.4 FUNCTIONAL REQUIREMENTS
Functional requirements define the core operational features, actions, and system behaviors implemented in the software.

**Table 3.1: Functional Requirements Matrix**
| Requirement ID | Module | Functional Description | Implementation Verification |
| :--- | :--- | :--- | :--- |
| **FR-01** | User Interface | The system shall provide a multi-tab dashboard displaying real-time asset counts, active BLE status, and recent security alerts. | Implemented & Verified in `main.dart` |
| **FR-02** | Asset Management | The user shall be able to register new assets by specifying name, category, description, safe-zone centroid, and radius. | Implemented & Verified via `/api/assets` |
| **FR-03** | Asset Modification | The user shall be able to update existing asset attributes (category, safe location, paired tracker ID) or delete registered assets. | Implemented & Verified via `PUT`/`DELETE` |
| **FR-04** | GPS Positioning | The mobile application shall request runtime location permissions and stream the smartphone's real-time latitude, longitude, and accuracy. | Implemented via `geolocator` |
| **FR-05** | Geocoding | The system shall perform reverse geocoding on raw geographic coordinates to display human-readable street and locality names. | Implemented via `geocoding` |
| **FR-06** | Geofence Boundary Check | The system shall compute the spherical distance between the host device and the asset safe zone, triggering an alert if the perimeter is breached. | Implemented using Haversine algorithm |
| **FR-07** | BLE Device Scanning | The system shall scan the 2.4 GHz ISM band for advertising BLE peripherals and display discovered device names, MAC addresses, and RSSI. | Implemented via `flutter_blue_plus` |
| **FR-08** | RSSI Categorization | The system shall continuously read RSSI from connected/detected peripherals and map values into Immediate, Near, Far, or Lost tiers. | Implemented via log-distance rules |
| **FR-09** | Alert Generation | The system shall generate timestamped security alerts for geofence breaches, tracker disconnections, and degraded RSSI conditions. | Implemented & Verified via `/api/alerts` |
| **FR-10** | Alert De-Duplication | The backend shall suppress duplicate alert submissions for the same asset and event type occurring within a 60-second temporal window. | Implemented in `alertRoutes.js` |
| **FR-11** | Spatial History Logging | The system shall record timestamped spatial coordinates, status flags, and RSSI metrics in the database for post-incident review. | Implemented via `/api/history` |

---

## 3.5 NON-FUNCTIONAL REQUIREMENTS
Non-functional requirements specify the operational criteria, behavioral quality attributes, and performance benchmarks governing system execution.

**Table 3.2: Non-Functional Requirements Specifications**
| Quality Attribute | Specification & Performance Target |
| :--- | :--- |
| **Usability & UX** | The mobile client shall adhere to Material Design principles, providing intuitive navigation across screens with high-contrast visual indicators. Interactive elements shall provide immediate tactile and visual feedback within 100 ms of user interaction. |
| **Performance & Latency**| The backend REST API shall process and respond to standard CRUD requests within an average response latency of less than 200 milliseconds under local network conditions. BLE scanning updates shall refresh at least once every 1.5 seconds during active scan cycles. |
| **Reliability & Fault Tolerance**| In the event of backend network failure, the mobile client shall gracefully degrade, maintaining local offline operational state using `shared_preferences` without application termination. Database reconnection attempts shall be handled automatically. |
| **Security & Privacy** | The application shall request only essential runtime OS permissions (Fine Location, Bluetooth Scan, Bluetooth Connect) with contextual explanations. API endpoints shall validate and sanitize all incoming JSON payloads to prevent injection attacks. |
| **Portability & Cross-Platform**| The mobile application shall maintain 100% functional and visual consistency across both Android (API 24+) and iOS operating systems from a single Dart codebase. The backend shall execute across any Node.js runtime environment (Linux, macOS, Windows). |
| **Maintainability & Modularity**| The software architecture shall adhere to separation-of-concerns principles. Database schemas, API routes, and presentation widgets shall reside in dedicated modular directories with comprehensive technical documentation. |

---

## 3.6 HARDWARE AND SOFTWARE REQUIREMENTS
The development, deployment, and operational execution of the system depend on specified hardware and software specifications.

**Table 3.3: Hardware and Software Development Requirements**
| Layer / Environment | Component Specification | Minimum Requirement | Recommended Specification |
| :--- | :--- | :--- | :--- |
| **Development Host Machine**| Processor | Intel Core i3 / AMD Ryzen 3 | Intel Core i5/i7 (11th Gen+) or Apple Silicon M1/M2 |
| &nbsp; | System Memory (RAM) | 8 GB DDR4 | 16 GB DDR4/DDR5 |
| &nbsp; | Storage | 256 GB SSD (10 GB free) | 512 GB NVMe SSD |
| &nbsp; | Operating System | Windows 10/11, Ubuntu 20.04+, macOS | Windows 11 (64-bit) / macOS Sonoma |
| **Mobile Client Device** | Operating System | Android 7.0 (API 24) or iOS 12.0 | Android 11.0+ (API 30+) or iOS 15.0+ |
| &nbsp; | Wireless Hardware | Bluetooth 4.0 (BLE support) | Bluetooth 5.0+ with Extended Advertising |
| &nbsp; | Satellite Hardware | Standard GNSS / GPS Receiver | Multi-Constellation GNSS (GPS + GLONASS + Galileo) |
| **Target BLE Tracker Hardware**| Wireless Protocol | Bluetooth Low Energy 4.0 / 4.2 / 5.0 | Open-standard BLE Beacon (iBeacon / Eddystone compatible) |
| &nbsp; | Transmit Power ($Tx$) | Fixed -59 dBm to 0 dBm | Programmable $Tx$ Power with CR2032 Coin Cell |
| **Software Development Tools**| Framework | Flutter SDK 3.13.x+ / Dart 3.1.x+ | Flutter SDK 3.19.x+ with Material 3 enabled |
| &nbsp; | Backend Runtime | Node.js v18.x LTS | Node.js v20.x LTS or v22.x LTS |
| &nbsp; | Backend Web Framework | Express.js v4.18+ | Express.js v4.19+ |
| &nbsp; | Database Management System | MongoDB Community Server 6.0+ | MongoDB Community Server 7.0+ or MongoDB Atlas Cloud |
| &nbsp; | Integrated Development Environment| VS Code / Android Studio | VS Code with Flutter, Dart, and Node.js Extension Packs |
| &nbsp; | API Verification Suite | cURL / Postman v10+ | Postman Desktop Client with Automated Test Collections |

---

## 3.7 FEASIBILITY ANALYSIS
A comprehensive feasibility study was conducted to evaluate the viability of the project across technical, economic, and operational dimensions:

### 3.7.1 Technical Feasibility
The technical feasibility evaluates whether the proposed system can be successfully engineered using existing technologies, frameworks, and team competencies:
- **Maturity of Tech Stack:** Flutter, Node.js, Express.js, and MongoDB are industry-standard, mature technologies supported by extensive documentation and active open-source communities.
- **Hardware Integration:** Modern mobile operating systems (Android and iOS) provide robust, well-documented native SDKs for GNSS positioning and Bluetooth Low Energy scanning. The `flutter_blue_plus` and `geolocator` packages wrap these native APIs into Dart asynchronous streams, abstracting platform-specific boilerplate.
- **Decoupled Architecture:** Using stateless RESTful communication over HTTP JSON ensures that the frontend and backend can be developed, tested, and scaled independently.
- **Conclusion:** The project is **technically feasible** and well within the engineering capabilities of the project team.

### 3.7.2 Economic Feasibility
Economic feasibility assesses the financial expenditures required to develop, deploy, and maintain the system:
- **Zero Software Licensing Costs:** All core development tools—including Flutter, Dart, Node.js, Express.js, MongoDB Community Edition, Visual Studio Code, and Git—are open-source and free for commercial and academic use.
- **Hardware Cost Optimization:** The system leverages the user's existing personal smartphone, eliminating the need to procure expensive specialized mobile receivers. Generic, open-standard BLE beacons are commercially available for $5 to $15 per unit, avoiding proprietary hardware markups.
- **Zero Recurring SIM Fees:** Unlike dedicated cellular GPS trackers, the system requires no cellular subscriptions for tracked peripherals.
- **Conclusion:** The project is **economically feasible**, requiring virtually zero capital investment for software development and minimal hardware expense.

### 3.7.3 Operational Feasibility
Operational feasibility evaluates how effectively the system fits into user workflows and solves the target problem:
- **Intuitive User Interface:** The mobile application provides an intuitive Material Design interface, requiring no specialized technical training. Users can register assets, configure geofences, and inspect alerts through straightforward graphical controls.
- **Minimal User Burden:** Once an asset is registered and safe zones are configured, the system operates autonomously in the background, monitoring wireless signals and spatial boundaries without demanding continuous active user engagement.
- **Academic and Enterprise Reusability:** The modular REST API and NoSQL database structure allow educational institutions, libraries, and corporate facilities to integrate the system directly into existing asset management databases.
- **Conclusion:** The system demonstrates **high operational feasibility**.

---

## 3.8 RISK ANALYSIS
Any software and hardware integration project entails inherent engineering risks. Table 3.4 identifies potential technical risks alongside concrete mitigation strategies implemented in the software architecture.

**Table 3.4: Project Risk Identification and Mitigation Matrix**
| Risk Identifier | Identified Technical Risk | Severity | Probability | Implemented Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **RSK-01** | **GPS Signal Occlusion:** Severe attenuation of satellite signals when moving indoors or into basements. | High | High | Gracefully detect location unavailability; fall back to the last recorded valid coordinates; leverage BLE proximity for local indoor monitoring. |
| **RSK-02** | **BLE RSSI Instability:** Signal fluctuations caused by multipath fading, walls, and human body obstruction triggering false-positive alerts. | High | High | Implement qualitative proximity zones rather than rigid distance thresholds; require consecutive degraded readings before triggering alerts. |
| **RSK-03** | **Network Connection Drop:** Inability to communicate with the Node.js/MongoDB backend when mobile data or Wi-Fi is lost. | Medium | High | Implement local persistence via `shared_preferences`; queue critical monitoring events locally; retry synchronization when connectivity is restored. |
| **RSK-04** | **Hardware Tracker Incompatibility:** Inability to discover or read telemetry from proprietary, closed-source tracking tags (e.g., Apple AirTags). | Medium | High | Explicitly document hardware boundaries; utilize open-standard BLE beacons (iBeacon/Eddystone); provide a transparent software simulation mode for academic testing. |
| **RSK-05** | **Alert Flooding:** Rapid generation of dozens of duplicate alert notifications during boundary oscillation or intermittent BLE connection. | Medium | Medium | Implement an automated 60-second temporal deduplication filter in the backend (`alertRoutes.js`), suppressing redundant identical alerts. |
| **RSK-06** | **Database Service Downtime:** Temporary unavailability of the local or cloud MongoDB daemon during application startup. | Low | Low | Design `server.js` with non-blocking error handling, allowing the Express HTTP server to start and respond with informative status codes even if the DB is offline. |

---

## 3.9 SUMMARY
This chapter presented an in-depth requirement and system analysis for the Smart Asset Protection and Hidden Tracking System. The limitations of traditional asset management and existing commercial tracking systems were analyzed. The proposed multi-tier architecture was introduced, followed by comprehensive functional and non-functional requirement specifications. Hardware and software dependencies were cataloged, and feasibility assessments confirmed the technical, economic, and operational viability of the project. Finally, a structured risk matrix outlined potential engineering challenges and their corresponding architectural mitigations. The next chapter presents the database design and data model.
