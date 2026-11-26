# Smart Asset Protection and Hidden Tracking System 🛡️📍

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Express.js](https://img.shields.io/badge/Express.js-5.x-000000?logo=express&logoColor=white)](https://expressjs.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Bluetooth Low Energy](https://img.shields.io/badge/BLE-Proximity%20Sensing-0082FC?logo=bluetooth&logoColor=white)](https://en.wikipedia.org/wiki/Bluetooth_Low_Energy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **A B.Tech Capstone Project**  
> **School of Computer Science and Artificial Intelligence (SCSAI)**  
> **SR University, Warangal, Telangana, India (Academic Year 2026–2027)**

---

## 📌 1. Project Introduction

The **Smart Asset Protection and Hidden Tracking System** is an end-to-end IoT mobile security application engineered to prevent loss, unauthorized removal, and misplacement of high-value personal belonging (electronics, bags, jewelry, documents, and vehicles).

By synergizing **Bluetooth Low Energy (BLE)** radio proximity sensing with **Smartphone GNSS/GPS Geofencing** and an asynchronous **Node.js/MongoDB** cloud backend, the system continuously monitors asset safety boundaries and delivers real-time anti-theft alerts both online and offline.

---

## ⚠️ 2. Problem Statement

Valuable portable assets are continuously vulnerable to misplacement, opportunistic theft, and accidental loss. Existing commercial tracking tags (such as Apple AirTag, Tile, or Samsung SmartTag) often suffer from:
1. **Proprietary Ecosystem Lock-in:** Strict dependency on proprietary smartphone networks and closed operating systems.
2. **Missing Custom Geofencing:** Inability for users to establish dynamic custom-radius safe zones around specific geographic points.
3. **Network Dependence:** Vulnerability to offline data loss when internet connectivity is intermittent.
4. **Limited Audit Trail:** Inadequate chronological event logging for security auditing and post-incident investigation.

There is a critical need for an open, cross-platform, multi-layered asset protection framework that delivers localized Bluetooth proximity verification, real-time geofence enforcement, and resilient offline synchronization.

---

## 🎯 3. Objectives

- **Dual-Layer Security Architecture:** Combine short-range Bluetooth Low Energy (BLE) beacon detection with long-range GPS geofencing.
- **Proximity & Signal Monitoring:** Continuously evaluate Received Signal Strength Indication (RSSI) and trigger proactive warnings before physical separation occurs.
- **Dynamic Geofence Enforcement:** Permit users to designate circular safe zones (20m to 1000m) with automatic breach detection using the Haversine distance formula.
- **Multi-User Data Isolation:** Ensure strict security and data privacy across distinct registered user accounts with per-user scoped storage and cloud collections.
- **Offline Fault Tolerance:** Provide seamless local caching (`SharedPreferences`) so tracking and alerting remain fully operational during server or network disconnects.
- **Interactive Open-Source Mapping:** Render real-time spatial locations, asset markers, and safe-zone perimeters using OpenStreetMap (`flutter_map`) without proprietary API key restrictions.

---

## ✨ 4. Key Features

| Feature | Description |
| :--- | :--- |
| **🔐 User Authentication** | Full Sign In & Registration workflow with per-user data isolation, session persistence, and local demo fallback mode. |
| **📦 Asset Lifecycle Management** | Register, inspect, edit, and delete assets categorized by electronics, jewelry, documents, luggage, and vehicles. |
| **📡 BLE Hardware Scanner** | Automated Bluetooth Low Energy scanner for detecting, pairing, and monitoring commercial tags and beacons. |
| **📶 Proximity & RSSI Alerts** | Continuous RSSI polling with configurable signal thresholds (-85 dBm) to warn of beacon attenuation and disconnects. |
| **🗺️ Live Geofence Mapping** | Interactive OpenStreetMap visualization depicting asset positions, safe-zone radii, and user movement vectors. |
| **🚨 Security Audit Engine** | Real-time security alerts categorized by severity (Critical, High, Medium, Info) with 45-second smart de-duplication. |
| **📜 Chronological History Trail**| Comprehensive audit log recording every GPS coordinate change, geofence status shift, and BLE handshake. |
| **🔄 Hybrid Dual-Storage Sync** | Automatic synchronization between local device cache and Node.js REST API with automatic Android emulator loopback routing (`10.0.2.2`). |
| **🧪 Demo Simulation Mode** | Integrated evaluation mode simulating real-world asset movement and RSSI attenuation for presentations and testing. |

---

## 🛠️ 5. Technologies Used

### Mobile Frontend
- **Framework:** [Flutter](https://flutter.dev) (v3.x) & [Dart](https://dart.dev) (v3.x)
- **Map Rendering:** `flutter_map` (v8.3.2) & `latlong2` (OpenStreetMap tile layers)
- **Spatial Positioning:** `geolocator` (v14.1.2) & `geocoding` (v5.0.1)
- **Hardware Communication:** `flutter_blue_plus` (v2.3.15) & `permission_handler` (v13.0.2)
- **State & Storage:** `shared_preferences` (v2.5.6) & `http` (v1.6.0)

### Backend & Cloud
- **Runtime Environment:** [Node.js](https://nodejs.org) (v18+)
- **Application Framework:** [Express.js](https://expressjs.com) (v5.x)
- **Database:** [MongoDB](https://www.mongodb.com) (Local Community Server / MongoDB Atlas)
- **ODM Library:** `mongoose` (v9.x)
- **Middleware:** `cors`, `dotenv`

---

## 📂 6. Project Folder Structure

```text
smart_asset_protection_hiddentracking_system/
│
├── android/                         # Native Android configuration, manifests & permissions
├── backend/                         # Node.js Express.js REST API Server
│   ├── models/                      # Mongoose Database Schemas
│   │   ├── Alert.js                 # Security alert schema
│   │   ├── Asset.js                 # Protected asset schema
│   │   ├── History.js               # Location & event audit schema
│   │   └── User.js                  # User authentication schema
│   ├── routes/                      # REST API Endpoint Handlers
│   │   ├── alertRoutes.js           # /api/alerts (GET, POST, PATCH, DELETE)
│   │   ├── assetRoutes.js           # /api/assets (CRUD + /tracker patch)
│   │   ├── authRoutes.js            # /api/auth (register, login, users)
│   │   └── historyRoutes.js         # /api/history (GET, POST, DELETE)
│   ├── .env.example                 # Environment configuration template
│   ├── package.json                 # Backend dependencies & run scripts
│   └── server.js                    # Express server entry point & MongoDB connection
│
├── docs/                            # Complete B.Tech Capstone Thesis Documentation
│   ├── 00_preliminary_pages.md      # Title, Certificate, Declaration & Acknowledgments
│   ├── 01_introduction.md           # Chapter 1: Introduction & Problem Context
│   ├── 02_literature_survey.md      # Chapter 2: Literature Survey & Related Work
│   ├── 03_system_analysis.md        # Chapter 3: Feasibility & Requirements Analysis
│   ├── 04_system_design.md          # Chapter 4: Architecture, UML & Database Design
│   ├── 05_implementation.md         # Chapter 5: Algorithm, Code & Technology Stack
│   ├── 06_software_testing.md       # Chapter 6: Test Cases (TC-01 to TC-15) & Results
│   ├── 07_results_discussion.md     # Chapter 7: Verification & Experimental Findings
│   ├── 08_conclusion.md             # Chapter 8: Capstone Summary & Future Enhancements
│   ├── 09_references.md             # Authentic IEEE References with DOIs
│   ├── 10_appendix_code.md          # Implementation Source Code Listings
│   ├── 11_appendix_api.md           # REST API Endpoint Documentation
│   └── 12_appendices.md             # Hardware Pinouts & Technical Specifications
│
├── lib/                             # Flutter Mobile Application Source Code
│   └── main.dart                    # Application entry point, UI views, BLE & Map controllers
│
├── screenshots/                     # Application UI captures and demo GIF assets
│   └── README.md                    # Visual media documentation guide
│
├── .gitignore                       # Git exclusion rules for Flutter, Node.js & OS files
├── pubspec.yaml                     # Flutter package dependencies and metadata
├── Smart_Asset_Protection_Hidden_Tracking_System_Complete_Report.md # Full master report
└── README.md                        # Master repository documentation
```

---

## 🚀 7. Installation and Setup Instructions

### Prerequisites
1. **Flutter SDK:** Version `^3.13.0` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
2. **Node.js & npm:** Version `18.x` or higher ([Install Node.js](https://nodejs.org))
3. **MongoDB:** Local Community Server running at `mongodb://127.0.0.1:27017` or a [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) cluster.
4. **Android Studio / VS Code:** Configured with Flutter and Dart extensions.
5. **Hardware (Optional for physical BLE):** Real Android device with Bluetooth 4.2+ and Location enabled, or an Android Studio AVD Emulator.

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/shivani-pabba/Smart-Asset-Protection-and-Hidden-Tracking-System.git
cd Smart-Asset-Protection-and-Hidden-Tracking-System
```

---

### Step 2: Setup and Start the Backend Server

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Configure environment variables
# Copy .env.example to .env (adjust PORT or MONGO_URI if necessary)
copy .env.example .env

# Start the Node.js server
node server.js
```

You should see:
```text
Routes loaded successfully: /api/auth, /api/assets, /api/alerts, /api/history
MongoDB Connected Successfully!
Server running on port 5000
```

---

### Step 3: Setup and Run the Flutter Mobile Application

Open a new terminal window at the project root directory:

```bash
# Fetch Flutter packages
flutter pub get

# Check environment readiness
flutter doctor

# Launch the application (connected Android phone or emulator)
flutter run
```

> **Note for Android Emulator:** The mobile application automatically resolves `127.0.0.1` to `10.0.2.2:5000` to seamlessly connect with the Node.js server running on your host machine.

---

## 📸 8. Screenshots Section

| Authentication Screen | Dashboard Overview | Protected Assets |
|:---:|:---:|:---:|
| *(User Login & Registration)* | *(Metrics, Battery & Status)* | *(Asset Safe-zone Configurations)* |
| <img src="screenshots/01_auth_login.png" width="240" alt="Auth Screen" onerror="this.src='https://via.placeholder.com/240x480?text=Auth+Screen';"/> | <img src="screenshots/02_dashboard_overview.png" width="240" alt="Dashboard" onerror="this.src='https://via.placeholder.com/240x480?text=Dashboard';"/> | <img src="screenshots/03_asset_registration.png" width="240" alt="Assets" onerror="this.src='https://via.placeholder.com/240x480?text=Asset+Registration';"/> |

| BLE Tracker Scanner | Live GPS Geofence Map | Security Audit Feed |
|:---:|:---:|:---:|
| *(RSSI Signal & Pairing)* | *(OpenStreetMap Perimeter)* | *(Real-time Incident Alerts)* |
| <img src="screenshots/04_ble_proximity.png" width="240" alt="BLE Scanner" onerror="this.src='https://via.placeholder.com/240x480?text=BLE+Scanner';"/> | <img src="screenshots/05_gps_live_map.png" width="240" alt="Live Map" onerror="this.src='https://via.placeholder.com/240x480?text=Geofence+Map';"/> | <img src="screenshots/06_security_alerts.png" width="240" alt="Alerts" onerror="this.src='https://via.placeholder.com/240x480?text=Security+Alerts';"/> |

*(Place PNG captures inside the `screenshots/` directory to display live imagery).*

---

## 👥 9. Team Members & Acknowledgements

### Project Team (B.Tech Computer Science & AI)
- **PABBA SHIVANI** (Roll No: `2303A510I4`) — *Project Lead, Full-Stack Mobile & Backend Architecture (Core Development)*
- **GANGILI SATHVIKA** (Roll No: `2303A510F9`) — *Team Member, UI Testing & Geofencing Research*
- **A. RAMYA SRI** (Roll No: `2303A51286`) — *Team Member, REST API & Database Modeling Verification*
- **SHAIK AFROZ** (Roll No: `2303A51983`) — *Team Member, BLE Hardware Proximity Evaluation*
- **SRIHITHA** — *Team Member, Quality Assurance & Technical Documentation*

### Faculty Mentorship & Institutional Support
- **Project Guide:** **Mr. L. Gunakar Rao**, Assistant Professor, Department of Computer Science and Artificial Intelligence.
- **Department:** School of Computer Science and Artificial Intelligence (SCSAI).
- **Institution:** **SR University**, Ananthasagar, Hasanparthy, Warangal, Telangana – 506371, India.

We express our gratitude to SR University and our department faculty for providing the technical infrastructure and academic mentorship that made this capstone project possible.

---

## 📄 10. License

This project is licensed under the **MIT License** — feel free to utilize, modify, and reference this work for academic and educational research.
