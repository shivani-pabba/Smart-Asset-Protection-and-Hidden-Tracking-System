# CHAPTER 4 – DATABASE DESIGN AND DATA MODEL

## 4.1 DATABASE OVERVIEW
Persistent data management represents a foundational pillar of the Smart Asset Protection and Hidden Tracking System. An effective asset security architecture requires a data store capable of recording dynamic physical attributes, variable spatial coordinates, streaming sensor telemetry, and asynchronous security alerts with high throughput, low latency, and schema flexibility.

In enterprise software engineering, database architectures are broadly bifurcated into two paradigms:
1. **Relational Database Management Systems (RDBMS):** Systems such as PostgreSQL, MySQL, and Oracle rely on rigid tabular schemas, predefined column types, and strict foreign-key constraints. While relational databases excel in financial transaction processing requiring strict ACID (Atomicity, Consistency, Isolation, Durability) guarantees, their rigid schema enforcement introduces friction when handling dynamic IoT telemetry, variable sensor payloads, and hierarchical document structures.
2. **Document-Oriented NoSQL Systems:** Systems such as MongoDB organize data into self-contained, flexible, JSON-like document hierarchies. Each document can maintain varying attribute structures, optional fields, and nested geographic sub-documents without requiring costly database migrations or schema alterations.

### Rationale for Selecting MongoDB:
MongoDB was selected as the persistent database engine for this capstone project based on specific technical advantages:
- **Natural Alignment with JavaScript/Dart Object Models:** The mobile client (Dart) and backend middleware (Node.js) natively represent assets and alerts as JavaScript Object Notation (JSON) maps. MongoDB stores data natively in Binary JSON (BSON), eliminating the object-relational impedance mismatch inherent in traditional SQL databases.
- **Dynamic Schema Flexibility:** As hardware tracking integrations evolve, new sensor fields (such as battery percentage, ambient temperature, firmware revisions, and acceleration vectors) can be appended to asset documents without altering existing legacy records.
- **High-Performance Asynchronous I/O:** MongoDB’s memory-mapped storage engine (WiredTiger) delivers exceptional write throughput, making it well-suited for streaming high-frequency spatial tracking history and event logs.
- **Native Geospatial Indexing Capabilities:** MongoDB provides native support for GeoJSON geometry primitives (Point, Polygon) and 2dsphere spatial indexing, enabling optimized radius queries and geospatial containment checks.

---

## 4.2 MONGODB ARCHITECTURE
MongoDB operates as a document-oriented, distributed NoSQL database server. The architectural flow of data between the Flutter mobile application, the Express/Node.js API middleware, and the underlying MongoDB instance is illustrated in Figure 4.1.

```
+---------------------------------------------------------------------------------------------------+
|                        MONGODB INTEGRATION ARCHITECTURE IN ASSET PROTECTION                       |
+---------------------------------------------------------------------------------------------------+

     [ Flutter Mobile Client ]
                 |
                 |  HTTPS / JSON Payload
                 v
     [ Express.js REST API Routes ]
       - /api/assets  (Asset CRUD & Tracker Status)
       - /api/alerts  (Security Notifications & De-Duplication)
       - /api/history (Spatial Coordinate & RSSI Logging)
                 |
                 |  Mongoose ODM (Object-Document Mapper)
                 v
     +-------------------------------------------------------------+
     |                    MONGOOSE SCHEMA LAYER                    |
     |   - AssetSchema    - AlertSchema    - HistorySchema         |
     |   - Type Checking  - Validations    - Default Initializers  |
     +-------------------------------------------------------------+
                 |
                 |  MongoDB Wire Protocol (TCP Port 27017)
                 v
     +-------------------------------------------------------------+
     |                  MONGODB DATABASE ENGINE                    |
     |                 [ smart_asset_protection ]                  |
     |                                                             |
     |   +-----------------------------------------------------+   |
     |   |                   COLLECTIONS                       |   |
     |   |                                                     |   |
     |   |   [ assets ]      [ alerts ]      [ histories ]     |   |
     |   |   (BSON Docs)     (BSON Docs)     (BSON Docs)       |   |
     |   +-----------------------------------------------------+   |
     |                               |                             |
     |                               v                             |
     |   [ WiredTiger Storage Engine (Data Cache & B-Tree Index) ] |
     |                               |                             |
     |                               v                             |
     |   [ Persistent File System Storage (.wt Data Files) ]        |
     +-------------------------------------------------------------+
```
*Figure 4.1: Architectural Diagram of MongoDB Integration in Asset Protection System*

### 4.2.1 Core Architectural Components:
1. **Database Instance:** The logical database container named `smart_asset_protection` houses all collections and configurations for the application.
2. **Collections:** Collections represent schema-free groupings of related BSON documents, functioning analogously to tables in relational database management systems.
3. **Documents:** Individual data records within a collection, encoded as binary JSON (BSON). Each document contains an immutable, globally unique primary key field: `_id` (an automatically generated 12-byte BSON ObjectId).
4. **Mongoose ODM Layer:** To enforce application-level type consistency and data integrity without compromising NoSQL flexibility, the backend employs the **Mongoose Object Data Modeling (ODM)** library. Mongoose manages schema definition, default value assignment, enumeration enforcement, and lifecycle hooks within the Node.js application process.

---

## 4.3 DATABASE COLLECTIONS
The database architecture partitions persistent state across three dedicated collections, summarized in Table 4.1.

**Table 4.1: Summary of MongoDB Collections and Storage Characteristics**
| Collection Name | Associated Mongoose Model | Primary Operational Role | Average Document Size | Retention Policy |
| :--- | :--- | :--- | :--- | :--- |
| **`assets`** | `Asset` (`Asset.js`) | Stores core asset inventory metadata, safe-zone centroid coordinates, geofence radius, and paired BLE tracker association status. | ~500 Bytes | Permanent (Lifecycle Managed by User) |
| **`alerts`** | `Alert` (`Alert.js`) | Logs timestamped security events (geofence breaches, BLE disconnection, weak RSSI) with severity indicators and read status. | ~350 Bytes | Rotational / User Cleared |
| **`histories`** | `History` (`History.js`) | Captures continuous chronological spatial telemetry, GPS coordinates, geofence status, and received RSSI readings. | ~280 Bytes | Historical Audit Trail |

---

## 4.4 DATA MODEL DESCRIPTION
The structural schema, field definitions, data types, constraints, and operational purposes of the individual database models are detailed below.

### 4.4.1 The Asset Collection Data Model
The `Asset` model encapsulates all attributes governing a tracked physical possession. Each document maintains both static descriptive metadata and dynamic sensor association parameters.

**Table 4.2: Asset Document Schema Specification**
| Field Identifier | BSON / Mongoose Type | Required | Default Value | Validated Enumeration / Constraints | Operational Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `_id` | `ObjectId` | Auto | Generated | Unique 12-byte identifier | Primary database key |
| `name` | `String` | Yes | None | Trimmed, Non-Empty String | Common name of the asset (e.g., "ThinkPad X1 Laptop") |
| `category` | `String` | Yes | None | Category classification | Classification (Electronics, Documents, Vehicles, etc.) |
| `description` | `String` | No | `""` | Free-form text | Contextual descriptive notes regarding the asset |
| `latitude` | `Number` | No | `null` | $-90.0 \le \phi \le +90.0$ | Safe-zone centroid latitude (WGS-84 decimal degrees) |
| `longitude` | `Number` | No | `null` | $-180.0 \le \lambda \le +180.0$ | Safe-zone centroid longitude (WGS-84 decimal degrees) |
| `safeLocation`| `String` | No | `""` | Human-readable address | Reverse-geocoded textual name of the safe zone |
| `radius` | `Number` | No | `100` | $25 \le r \le 1000$ (Meters) | Geofence safe perimeter radius surrounding centroid |
| `trackerId` | `String` | No | `null` | Hardware MAC / UUID String | Paired BLE beacon hardware identifier |
| `trackerName`| `String` | No | `null` | Advertised string | Advertised peripheral name captured during scan |
| `trackerStatus`| `String` | No | `'unpaired'`| `'connected'`, `'disconnected'`, `'searching'`, `'unpaired'` | Real-time BLE link state |
| `lastRssi` | `Number` | No | `null` | Signal strength in dBm | Most recent measured Bluetooth signal strength |
| `lastDetected`| `Date` | No | `null` | ISO 8601 Timestamp | Precise epoch of the last successful BLE packet reception |
| `userId` | `String` | No | `'default_user'`| User identity reference | Identifies the owner/custodian account |
| `movementLatitude`| `Number` | No | `null` | WGS-84 Latitude | Real-time location coordinate during movement |
| `movementLongitude`| `Number` | No | `null` | WGS-84 Longitude | Real-time location coordinate during movement |
| `isOutside` | `Boolean` | No | `false` | Boolean flag | Real-time perimeter breach indicator ($d > \text{radius}$) |
| `createdAt` | `Date` | No | `Date.now` | ISO 8601 Timestamp | Audit timestamp of document initial creation |

### 4.4.2 The Security Alert Collection Data Model
The `Alert` model records discrete security incidents detected by the monitoring engine, supporting temporal deduplication and read-state management.

**Table 4.3: Security Alert Document Schema Specification**
| Field Identifier | BSON / Mongoose Type | Required | Default Value | Validated Enumeration / Constraints | Operational Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `_id` | `ObjectId` | Auto | Generated | Unique 12-byte identifier | Primary database key |
| `title` | `String` | Yes | None | Concise event header | Alert title (e.g., "Safe Zone Exit Detected") |
| `assetId` | `ObjectId` | No | `null` | Ref: `'Asset'` | Foreign key reference to target asset document |
| `assetName` | `String` | No | `'System'` | Non-empty string | Snapshot of asset name at incident epoch |
| `description` | `String` | Yes | None | Detailed event narrative | Narrative explaining cause, coordinates, or RSSI |
| `alertType` | `String` | No | `'system'` | `'safe_zone'`, `'tracker_disconnected'`, `'tracker_not_detected'`, `'weak_rssi'`, `'system'` | System categorization of alert trigger |
| `severity` | `String` | No | `'medium'` | `'low'`, `'medium'`, `'high'`, `'critical'` | Priority level governing UI badge presentation |
| `isRead` | `Boolean` | No | `false` | Boolean flag | Indicates whether the user acknowledged the alert |
| `userId` | `String` | No | `'default_user'`| User identity reference | Identifies the recipient user profile |
| `timestamp` | `Date` | No | `Date.now` | ISO 8601 Timestamp | Precise time when the security event was triggered |

### 4.4.3 The Spatial History Collection Data Model
The `History` model stores time-series location coordinates and radio signal metrics, providing an audit trail of movement.

**Table 4.4: Spatial History Document Schema Specification**
| Field Identifier | BSON / Mongoose Type | Required | Default Value | Validated Enumeration / Constraints | Operational Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `_id` | `ObjectId` | Auto | Generated | Unique 12-byte identifier | Primary database key |
| `assetId` | `ObjectId` | No | `null` | Ref: `'Asset'` | Foreign reference to associated asset |
| `assetName` | `String` | Yes | None | Non-empty string | Redundant asset name for fast querying |
| `safeName` | `String` | No | `""` | Textual safe zone name | Assigned safe zone label |
| `latitude` | `Number` | Yes | None | WGS-84 Coordinate | Host device latitude at recording epoch |
| `longitude` | `Number` | Yes | None | WGS-84 Coordinate | Host device longitude at recording epoch |
| `status` | `String` | No | `'Inside Safe Zone'`| Free-form status flag | Human-readable geofence condition summary |
| `historyType` | `String` | No | `'gps'` | `'gps'`, `'tracker'`, `'geofence'`| Telemetry channel source |
| `rssi` | `Number` | No | `null` | Radio signal strength in dBm | BLE signal strength reading, if available |
| `userId` | `String` | No | `'default_user'`| User identity reference | Associated user profile identifier |
| `timestamp` | `Date` | No | `Date.now` | ISO 8601 Timestamp | Exact epoch of telemetry acquisition |

---

## 4.5 MONGODB DATA MODEL DIAGRAMS AND SCHEMAS
Figure 4.2 illustrates the document model relationships across the three primary collections.

```
+---------------------------------------------------------------------------------------------------+
|                        MONGODB DOCUMENT RELATIONSHIP AND ENTITY DIAGRAM                           |
+---------------------------------------------------------------------------------------------------+

     +---------------------------------------------------------+
     |                    ASSET COLLECTION                     |
     +---------------------------------------------------------+
     | _id: ObjectId <PK>                                      |
     | name: String                                            |
     | category: String                                        |
     | description: String                                     |
     | latitude: Number (Centroid Lat)                         |
     | longitude: Number (Centroid Lon)                        |
     | safeLocation: String (Place Name)                       |
     | radius: Number (Geofence Radius in meters)              |
     | trackerId: String (BLE MAC / Hardware UUID)             |
     | trackerName: String (Advertised Name)                   |
     | trackerStatus: Enum ('connected','disconnected',...)    |
     | lastRssi: Number (Measured dBm)                         |
     | lastDetected: Date                                      |
     | userId: String                                          |
     | movementLatitude: Number                                |
     | movementLongitude: Number                               |
     | isOutside: Boolean                                      |
     | createdAt: Date                                         |
     +---------------------------------------------------------+
            | 1                                  | 1
            |                                    |
            | 0..* (Generates)                   | 0..* (Records)
            v                                    v
     +------------------------------+     +-------------------------------+
     |       ALERT COLLECTION       |     |      HISTORY COLLECTION       |
     +------------------------------+     +-------------------------------+
     | _id: ObjectId <PK>           |     | _id: ObjectId <PK>            |
     | title: String                |     | assetId: ObjectId <Ref Asset> |
     | assetId: ObjectId <Ref Asset>|     | assetName: String             |
     | assetName: String            |     | safeName: String              |
     | description: String          |     | latitude: Number              |
     | alertType: Enum              |     | longitude: Number             |
     | severity: Enum               |     | status: String                |
     | isRead: Boolean              |     | historyType: Enum             |
     | userId: String               |     | rssi: Number                  |
     | timestamp: Date              |     | userId: String                |
     +------------------------------+     | timestamp: Date               |
                                          +-------------------------------+
```
*Figure 4.2: MongoDB Document Model & Entity Relationships*

### Implementation Source Excerpt: Mongoose Schemas
The schema models are implemented directly in `backend/models/Asset.js`, `backend/models/Alert.js`, and `backend/models/History.js`. For example, the `Asset` schema is defined using Mongoose as follows:

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

---

## 4.6 DATA VALIDATION AND SECURITY
Data integrity and security are enforced across multiple architectural layers:

### 4.6.1 Schema-Level Data Validation
Mongoose models enforce strict type validation before data can be written to the database:
- **String Trimming & Type Coercion:** Ensures empty strings or invalid types are rejected with structured HTTP 400 Bad Request responses.
- **Enumeration Constraints:** The `trackerStatus`, `alertType`, `severity`, and `historyType` fields strictly reject values outside their defined sets.
- **Coordinate Boundaries:** Geodetic coordinates are validated to ensure latitude resides within $[-90, +90]$ and longitude within $[-180, +180]$.

### 4.6.2 Temporal Alert De-Duplication Logic
To prevent database flooding during intermittent radio connectivity or geofence boundary oscillation, the backend implements an automated deduplication filter in `backend/routes/alertRoutes.js`:

```javascript
// Query for an existing alert with identical title & asset within the last 60 seconds
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
```
This ensures that transient fluctuations do not pollute the database with duplicate records.

### 4.6.3 Indexing and Query Optimization
To maintain rapid query performance as collections grow:
- **`createdAt: -1` and `timestamp: -1` Indexes:** Default compound indexes on timestamp fields enable fast chronological sorting for dashboard queries.
- **`userId` Filtering:** Secondary indexing on `userId` optimizes multi-user tenant separation without requiring complex joins.

---

## 4.7 SUMMARY
This chapter detailed the database architecture and document schemas implemented for the Smart Asset Protection and Hidden Tracking System. The technical rationale for selecting a document-oriented NoSQL engine (MongoDB) over relational databases was established. The internal architectural layers of MongoDB and the Mongoose ODM were illustrated. Comprehensive schema specifications and data dictionaries were defined for the `assets`, `alerts`, and `histories` collections. Finally, data validation rules, temporal alert deduplication logic, and indexing strategies were presented. The next chapter details the proposed methodology.
