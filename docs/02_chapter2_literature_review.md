# CHAPTER 2 – LITERATURE REVIEW

## 2.1 INTRODUCTION
Asset protection, wireless tracking, and indoor positioning systems have emerged as major research domains within computer science, communications engineering, and the Internet of Things (IoT). The fundamental goal of these systems is to determine the spatial location, physical state, and security status of valuable physical items across diverse operational environments. Over the past three decades, researchers and industrial practitioners have explored a broad spectrum of tracking paradigms, ranging from global satellite navigation systems to short-range wireless radio frequency technologies, optical identification methods, and acoustic sensing.

This chapter presents a comprehensive, scholarly review of foundational and contemporary literature pertaining to smart asset protection. It examines:
- The theoretical principles and operational trade-offs of Global Navigation Satellite Systems (GNSS / GPS) [4], [7].
- The architecture and energy-efficiency mechanisms of Bluetooth Low Energy (BLE) [1], [2], [10].
- The mathematical foundations and physical limitations of Received Signal Strength Indicator (RSSI) proximity and distance estimation [5], [6], [8], [11], [14].
- Advanced indoor positioning paradigms, including trilateration, fingerprinting, and filtering methods [2], [9], [12], [15], [16].
- Geospatial perimeter algorithms and dynamic geofencing methodologies [3].
- The identified research gaps in current literature and commercial solutions, situating the contribution of the Smart Asset Protection and Hidden Tracking System within the state of the art.

---

## 2.2 RELATED RESEARCH
The academic landscape of asset tracking and positioning spans outdoor satellite navigation and indoor short-range wireless sensing:

### 2.2.1 Satellite-Based Positioning and Mobile GNSS
Zangenehnejad and Gao [4] presented a comprehensive investigation into GNSS smartphone positioning, documenting recent technological advances, structural challenges, and future perspectives. Their study analyzed how multi-frequency, multi-constellation GNSS chipsets embedded in commercial smartphones have improved raw positioning precision in open-sky outdoor conditions. However, their research emphasized severe degradation in urban canyons and indoor environments, where satellite signals suffer from non-line-of-sight (NLOS) reception, atmospheric delays, and multipath interference.

Dabove et al. [7] conducted extensive empirical evaluations of GNSS positioning using Android mobile devices. They investigated the availability of raw GNSS measurements and carrier-phase data in modern mobile operating systems. Their findings demonstrated that while single-point positioning yields an accuracy of 3 to 10 meters under optimal conditions, structural obstructions—such as concrete floors and steel framing—rapidly attenuate satellite signals below the receiver's acquisition sensitivity threshold, rendering standalone smartphone GPS ineffective inside buildings.

### 2.2.2 Bluetooth Low Energy and Indoor Wireless Sensing
To overcome satellite signal blockage in enclosed architectural structures, researchers turned to short-range radio frequency technologies. Bluetooth Low Energy (BLE) has received widespread adoption due to its low power consumption, cost-effective silicon transceivers, and universal support across consumer smartphones.

Milano et al. [1] provided an in-depth analysis of BLE-based indoor localization, evaluating methodologies for performance improvement. They demonstrated that BLE beacons broadcasting periodic advertisement packets on 2.4 GHz channels enable mobile devices to perform real-time proximity sensing. Their work highlighted the trade-off between beacon advertising intervals (which dictate battery longevity) and mobile detection latency.

Cantón Paterna et al. [2] engineered a BLE indoor positioning system utilizing channel diversity, weighted trilateration, and Kalman filtering. Their research demonstrated that radio frequency interference and multipath reflections in indoor spaces cause rapid fluctuations in received signal strength. By collecting measurements across all three primary BLE advertising channels (Channels 37, 38, and 39) and applying recursive Kalman filtering to smooth raw RSSI telemetry, they achieved significant reductions in spatial positioning error.

### 2.2.3 RSSI Estimation, Filtering, and Machine Learning
The Received Signal Strength Indicator (RSSI) provides an indirect measure of the physical separation between a radio transmitter and receiver. However, translating raw RSSI into reliable metric distance represents a challenging problem in wireless communications.

Janczak et al. [5] conducted an accuracy analysis of indoor location systems based on BLE RSSI measurements, evaluating path-loss model deviations across complex office layouts. Their experimental results proved that environmental geometry, wall materials, and furniture layout heavily alter the empirical path-loss exponent, confirming that raw RSSI provides qualitative proximity zones rather than deterministic metric distances.

Filus et al. [8] developed a cost-effective filtering framework for proximity detection based on smartphone BLE RSSI and Inertial Measurement Unit (IMU) sensor readings. Their work proved that fusing radio signal strength with smartphone accelerometer and gyroscope data significantly suppresses false-positive separation alerts caused by temporary body shadowing (e.g., when a user places their phone in a pocket or blocks the line of sight).

Subsequent studies explored fingerprinting and advanced data fusion. In [9], a lightweight fingerprint map combined with BLE iBeacons enabled smartphone indoor localization without requiring complex ray-tracing models. In [10], researchers compared trilateration, fingerprinting, and centroid algorithms, noting that while fingerprinting delivers superior precision in static environments, it requires costly site-survey calibration, making simple proximity thresholding more suitable for agile asset tracking. Recent advancements by researchers in [11] introduced an RSSI mean estimator for emergency evacuation tracking, while [12] and [16] explored hybrid Angle-of-Arrival (AoA), Kalman filtering, and Wi-Fi/BLE data fusion for industrial tracking.

---

## 2.3 EXISTING ASSET TRACKING TECHNOLOGIES
Numerous technological paradigms have been engineered to track, catalog, and protect physical assets. Each approach presents distinct architectural advantages and operational constraints, summarized below:

```
+-----------------------------------------------------------------------------------------+
|                         COMPARISON OF ASSET TRACKING PARADIGMS                          |
+-----------------------------------------------------------------------------------------+
|  PARADIGM       | RANGE        | POWER NEED   | HARDWARE COST | ACCURACY     | LIVE DATA|
+-----------------+--------------+--------------+---------------+--------------+----------+
|  Active GPS     | Global       | Very High    | High ($50-$200)| 3m - 15m     | Yes (Cell|
|  Passive RFID   | < 3 meters   | Zero (Tag)   | Very Low      | Zone level   | No       |
|  Active RFID    | < 100 meters | Moderate     | Moderate      | Room level   | Yes      |
|  Optical / QR   | Line-of-sight| Zero         | Negligible    | Exact (Scan) | No       |
|  BLE Beacons    | 10m - 50m    | Ultra-Low    | Low ($5-$25)  | Proximity    | Yes      |
|  Proposed Dual  | Multi-Tier   | Smartphone   | Low (Standard | Dual Layer   | Yes      |
|  (GPS + BLE)    | (Local+Wide) | Optimized    | Smartphone)   | (Safe + Prox)| (Hybrid) |
+-----------------------------------------------------------------------------------------+
```

### 2.3.1 Passive Optical Tagging (Barcodes and QR Codes)
Visual optical tagging involves affixing two-dimensional matrix symbologies (QR codes) or linear barcodes to asset surfaces. Reading requires an optical sensor or smartphone camera with an uninterrupted line-of-sight. While virtually free to produce and highly reliable for cataloging stationary inventory, optical tagging is entirely passive. It cannot detect physical movement, cannot trigger alarms when an asset is displaced, and requires explicit manual intervention to register an event.

### 2.3.2 Radio Frequency Identification (RFID)
RFID systems utilize electromagnetic coupling in the radio frequency spectrum to interrogate tags:
- **Passive RFID:** Relies on electromagnetic energy harvested from an external RFID reader's interrogating radio frequency field. Passive tags have no internal battery, resulting in indefinite lifespan and negligible unit cost. However, read ranges are typically restricted to under 3 meters, and detection requires expensive, fixed RFID reader portals installed at building choke points.
- **Active RFID:** Employs battery-powered tags that broadcast beacon signals over distances up to 100 meters. While active RFID supports automated detection, proprietary reader infrastructure costs thousands of dollars, making it impractical for consumer and small-team asset protection.

### 2.3.3 Active Cellular-GPS Tracking Units
Dedicated GPS tracking units incorporate an onboard satellite receiver, a micro-controller, and a cellular modem (GSM/GPRS/LTE). These units continuously calculate geographical coordinates and transmit spatial telemetry to remote cloud servers over cellular data links. While providing true global tracking capabilities in outdoor environments, their operational viability for personal asset protection is severely constrained by:
1. High electrical current consumption, requiring battery recharging every few days.
2. Substantial physical dimensions and weight, preventing covert or unobtrusive attachment to small items.
3. Recurring monthly cellular data subscription fees per tag.
4. Total loss of satellite signal inside enclosed buildings, basements, and metal transit containers.

### 2.3.4 Commercial Consumer BLE Trackers (Apple AirTag, Tile, Samsung SmartTag)
Consumer BLE trackers utilize Bluetooth Low Energy advertising to communicate with nearby mobile devices. Products such as Apple AirTag and Samsung SmartTag leverage crowdsourced mesh networks, where millions of third-party consumer devices passively detect nearby tags and relay encrypted coordinates to proprietary cloud servers. While highly effective, these commercial ecosystems are closed:
- They enforce strict platform lock-in (e.g., Apple AirTags require an iOS device for full pairing and location tracking).
- They provide zero public REST API endpoints for institutional inventory database integration.
- They lack customizable geofencing radii and programmable security alert rules.
- They do not allow custom data model extensions required by enterprise and educational asset management workflows.

Table 2.1 provides a structured comparative summary of these technologies.

**Table 2.1: Comparison of Existing Asset Tracking Technologies**
| Technology Category | Primary Operating Medium | Typical Range | Energy Source | Infrastructure Requirement | Key Limitation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GPS Tracking Units** | GNSS Satellite Signals + Cellular | Global (Outdoor) | Rechargeable Battery (High Drain) | Cellular Base Stations & Satellites | Rapid battery drain; fails indoors; recurring SIM subscription costs. |
| **Bluetooth Low Energy** | 2.4 GHz ISM Radio Band | 10 – 70 meters | Coin Cell (CR2032) / 1–3 Years | Smartphones / BLE Gateways | Limited range; qualitative proximity only; RF multipath noise. |
| **Passive RFID** | LF/HF/UHF Electromagnetic Fields | 0.1 – 5 meters | Harvested RF Energy (Zero Battery) | High-Cost Fixed Reader Portals | Extremely short range; cannot provide continuous spatial monitoring. |
| **QR Code / Barcode** | Optical Line-of-Sight | 0.1 – 1 meter | None (Printed Matrix) | Camera / Optical Scanner | Zero real-time monitoring; purely passive; requires line-of-sight. |
| **Proposed Hybrid System** | Dual: GNSS Satellites + 2.4 GHz BLE | Multi-Tiered (Local + Wide-Area) | Smartphone Battery + BLE Coin Cell | Standard Smartphone + Open BLE Tag | Smartphone GPS tracks phone, not detached asset; BLE yields proximity. |

---

## 2.4 GPS-BASED TRACKING SYSTEMS
The Global Positioning System (GPS), managed by the United States Space Force, forms part of the broader Global Navigation Satellite System (GNSS) infrastructure, alongside European Galileo, Russian GLONASS, and Chinese BeiDou constellations.

### 2.4.1 Principles of Satellite Trilateration
GNSS satellites orbit the Earth at approximately 20,200 kilometers altitude, continuously transmitting synchronized radio frequency signals containing orbital ephemeris data and atomic clock timestamps. A terrestrial GPS receiver determines its three-dimensional coordinates (latitude, longitude, and ellipsoidal altitude) alongside receiver clock bias by solving a system of pseudorange equations from at least four non-co-planar satellites:

$$\rho_i = c \cdot (t_r - t_{s,i}) = \sqrt{(x_i - x_u)^2 + (y_i - y_u)^2 + (z_i - z_u)^2} + c \cdot \delta t_u - c \cdot \delta t_{s,i} + I_i + T_i + \epsilon_i$$

Where:
- $\rho_i$ denotes the measured pseudorange to satellite $i$.
- $c$ represents the speed of light in a vacuum ($2.99792458 \times 10^8\text{ m/s}$).
- $t_r$ and $t_{s,i}$ represent the signal reception and transmission epochs.
- $(x_u, y_u, z_u)$ represent the unknown receiver Cartesian coordinates in the WGS-84 coordinate frame.
- $(x_i, y_i, z_i)$ represent the known Cartesian coordinates of satellite $i$.
- $\delta t_u$ is the unknown receiver clock offset.
- $\delta t_{s,i}$ is the satellite clock error.
- $I_i$ and $T_i$ represent ionospheric and tropospheric propagation delays.
- $\epsilon_i$ captures unmodeled multipath and thermal noise errors.

Modern mobile operating systems utilize Assisted GPS (A-GPS), leveraging cellular base stations and Wi-Fi positioning system (WPS) databases to accelerate Time-To-First-Fix (TTFF) from minutes to seconds.

### 2.4.2 Comparative Characteristics: GPS vs. BLE
To address technical misconceptions, Table 2.2 presents a rigorous comparative analysis between satellite GPS tracking and Bluetooth Low Energy proximity sensing.

**Table 2.2: Comparative Analysis between GPS Satellite Tracking and BLE Proximity**
| Technical Parameter | GPS Satellite Tracking | Bluetooth Low Energy (BLE) |
| :--- | :--- | :--- |
| **Operating Physical Layer** | UHF Satellite Downlink (L1: 1575.42 MHz) | 2.4 GHz ISM Band (2402 – 2480 MHz) |
| **Tracking Geometry** | Wide-Area Global Spatial Coordinates | Local Short-Range Relative Proximity |
| **Physical Target Tracked** | The Host Device (Smartphone / Receiver) | Compatible Peripheral / Tag within Range |
| **Indoor Penetration** | Extremely Poor (Heavy attenuation by concrete/metal) | Moderate (Penetrates drywall, wooden partitions) |
| **Power Consumption** | High (50 – 150 mA active receiver draw) | Ultra-Low (10 – 15 mA during active Rx/Tx) |
| **Spatial Output Format** | Absolute Latitude & Longitude (WGS-84 Decimal Degrees)| Relative RSSI in dBm / Qualitative Distance Tier |
| **Primary Failure Modes** | Satellite occlusion, urban canyon multipath, cloud cover| Multipath fading, RF interference, human body shadowing|

---

## 2.5 BLUETOOTH LOW ENERGY (BLE)
Bluetooth Low Energy was introduced in Bluetooth Core Specification version 4.0 as an ultra-low-power wireless protocol distinct from legacy Bluetooth Classic. BLE was specifically designed for applications requiring intermittent transmission of small data packets with minimal energy expenditure.

### 2.5.1 Spectrum Allocation and Physical Layer Architecture
BLE operates within the 2.4 GHz Industrial, Scientific, and Medical (ISM) unlicensed radio spectrum (2400 MHz to 2483.5 MHz). The spectrum is partitioned into 40 discrete physical channels spaced 2 MHz apart:
- **Primary Advertising Channels (Channels 37, 38, 39):** Allocated at frequencies 2402 MHz, 2426 MHz, and 2480 MHz. These specific frequencies were intentionally chosen to avoid overlap with the most widely used Wi-Fi channels (Wi-Fi Channels 1, 6, and 11 in 802.11b/g/n), minimizing co-channel radio interference.
- **General Data Channels (Channels 0 through 36):** Allocated across the remaining spectrum for bi-directional, frequency-hopping data transfer once a peer-to-peer connection is established.

```
       CH 37                  CH 38                              CH 39
     (2402 MHz)             (2426 MHz)                         (2480 MHz)
        |                      |                                  |
   +----+--+-------------------+--+-------------------------------+--+----+
   | 37 | 0| 1| ... | 10| 11| 38| 12| ... | 35| 36| 39                       |
   +----+--+-------------------+--+-------------------------------+--+----+
   |<---------------------- 2.4 GHz ISM BAND -------------------------------->|
        ^                      ^                                  ^
     Wi-Fi Ch 1             Wi-Fi Ch 6                         Wi-Fi Ch 11
      Avoided                Avoided                            Avoided
```

### 2.5.2 Advertising and Connection States
In asset protection architectures, the BLE device attached to the physical asset operates as a **Peripheral / Broadcaster**, while the supervising smartphone acts as a **Central / Observer**:
1. **Advertising State:** The peripheral periodically broadcasts non-connectable or connectable advertising packets (`ADV_IND`, `ADV_NONCONN_IND`) across the three advertising channels at a configured Advertising Interval (e.g., 200 ms to 1000 ms). Each packet contains the device MAC address, transmission power level ($Tx\text{ Power}$), and custom payload structures (such as Apple iBeacon, Google Eddystone, or custom manufacturer telemetry).
2. **Scanning State:** The central smartphone activates its radio receiver across Channels 37, 38, and 39 during discrete scan windows. When an advertising frame is intercepted, the smartphone's Bluetooth controller measures the received carrier wave strength, calculates the RSSI in dBm, and passes the frame to the application layer.
3. **Connected State (GATT Profile):** If supported and requested, the central device can initiate a point-to-point connection with the peripheral, establishing a Generic Attribute Profile (GATT) hierarchy comprising Services, Characteristics, and Descriptors.

Table 2.3 provides a structured summary of the technologies synthesized in this project.

**Table 2.3: Comprehensive Technology Stack Summary**
| Layer / Component | Technology Selected | Operational Role in System |
| :--- | :--- | :--- |
| **Mobile Client Framework** | Flutter (Dart SDK ^3.13) | Cross-platform UI, state management, asynchronous event streams |
| **Satellite Positioning Engine**| `geolocator: ^14.1.2` | Mobile GNSS acquisition, WGS-84 coordinate streaming, distance math |
| **Spatial Reverse Geocoding** | `geocoding: ^5.0.1` | Converts raw geographic coordinates into human-readable place names |
| **BLE Radio Interfacing** | `flutter_blue_plus: ^2.3.15` | Native BLE adapter scanning, device discovery, GATT interrogation |
| **Mapping & Geospatial UI** | `flutter_map: ^8.3.2` & `latlong2`| Interactive vector tile rendering, geofence radius circle overlays |
| **Backend Runtime & API** | Node.js & Express.js | Stateless RESTful web services, CORS handling, business logic |
| **Persistent Cloud Database**| MongoDB (Mongoose ODM) | Non-relational document storage for assets, spatial histories, alerts |
| **Local Cache & Offline Storage**| `shared_preferences: ^2.5.6` | Resilient local key-value store for offline fallback operation |

---

## 2.6 RSSI-BASED PROXIMITY MONITORING
Received Signal Strength Indicator (RSSI) is a measurement of the power present in a received radio frequency signal, expressed logarithmically in decibels relative to one milliwatt (dBm):

$$P_{\text{dBm}} = 10 \cdot \log_{10}\left(\frac{P_{\text{mW}}}{1\text{ mW}}\right)$$

In typical Bluetooth Low Energy communication, received signal strength ranges from approximately **$-30\text{ dBm}$** (indicating extreme physical proximity, less than 0.5 meters) down to **$-95\text{ dBm}$** or **$-100\text{ dBm}$** (the thermal noise floor and receiver sensitivity limit).

### 2.6.1 The Log-Distance Path Loss Model
The theoretical attenuation of an electromagnetic wave propagating through free space obeys the inverse-square law. In terrestrial indoor environments characterized by absorption, reflection, and diffraction, radio propagation is modeled using the empirical **Log-Distance Path Loss Model**:

$$\text{RSSI}(d) = \text{RSSI}(d_0) - 10 \cdot n \cdot \log_{10}\left(\frac{d}{d_0}\right) + X_\sigma$$

Where:
- $d$ is the actual physical distance between the transmitting BLE peripheral and the receiving smartphone.
- $d_0$ represents the reference calibration distance (standardized in BLE systems as $d_0 = 1.0\text{ meter}$).
- $\text{RSSI}(d_0)$ (often denoted as the $Tx\text{ Power}$ or Measured Power) is the received signal strength measured at 1 meter in an unobstructed line-of-sight environment (typically calibrated between $-59\text{ dBm}$ and $-65\text{ dBm}$).
- $n$ is the **Path-Loss Exponent**, a dimensionless parameter reflecting the rate of signal decay relative to environment geometry:
  - Free space / open field: $n \approx 2.0$
  - Office building with line-of-sight: $n \approx 1.6 - 1.8$
  - Dense indoor office with drywall and furniture: $n \approx 2.7 - 3.5$
  - Industrial concrete/metal structures: $n \approx 4.0 - 6.0$
- $X_\sigma$ is a zero-mean Gaussian distributed random variable with standard deviation $\sigma$ ($X_\sigma \sim \mathcal{N}(0, \sigma^2)$), modeling environmental shadow fading.

### 2.6.2 Derivation of Distance Estimation from RSSI
By rearranging the Log-Distance Path Loss equation, the estimated metric distance $\hat{d}$ can be expressed mathematically as:

$$\hat{d} = d_0 \cdot 10^{\left(\frac{\text{RSSI}(d_0) - \text{RSSI}(d)}{10 \cdot n}\right)}$$

### 2.6.3 Physical Sources of RSSI Volatility
While the mathematical formulation is theoretically straightforward, calculating exact metric distance from RSSI in real-world scenarios is fundamentally flawed due to three primary radio frequency phenomena:
1. **Multipath Fading:** The transmitted 2.4 GHz signal reflects off metal surfaces, desks, walls, and floors. These multiple reflected wave components arrive at the receiving antenna with varying phase shifts, causing constructive or destructive interference that can alter instantaneous RSSI by $\pm 10\text{ dBm}$ without any physical movement.
2. **Human Body Shadowing:** Human tissue is primarily composed of water, which readily absorbs 2.4 GHz radio frequencies. When a user steps between the smartphone and the BLE tag, the signal can experience an immediate 8 to 15 dBm attenuation drop.
3. **Antenna Polarization and Orientation:** Commercial smartphone antennas have non-isotropic radiation patterns. Rotating the phone in the hand alters the antenna polarization alignment, inducing significant signal variations.

### 2.6.4 Architectural Mitigation: Qualitative Proximity Tiers
Recognizing these physical constraints, the Smart Asset Protection System avoids unreliable metric distance claims. Instead, the application implements a robust **discrete proximity categorization engine**, segmenting continuous RSSI values into four operational zones:
- **Immediate Proximity ($\ge -60\text{ dBm}$):** The asset is in direct physical custody (in hand, pocket, or adjacent desk; $\hat{d} < 1.5\text{ m}$).
- **Near Proximity ($-61\text{ dBm}$ to $-75\text{ dBm}$):** The asset is within the same room or immediate conversational space ($\hat{d} \approx 1.5\text{ m} - 5.0\text{ m}$).
- **Far Proximity ($-76\text{ dBm}$ to $-85\text{ dBm}$):** The asset is at the boundary of reliable detection, separated by walls or distance ($\hat{d} \approx 5.0\text{ m} - 15.0\text{ m}$).
- **Out of Range / Lost ($< -85\text{ dBm}$ or No Packets):** The asset's signal is undetectable, indicating separation or battery depletion.

---

## 2.7 GEOFENCING AND SECURITY ALERTS
Geofencing is a location-based architecture that establishes a virtual boundary around a specified geographical location. In smart asset protection, geofencing provides a supervisory boundary: if a user leaves their designated safe haven (e.g., home or workplace) while their asset is not in proximity, the system immediately recognizes a security vulnerability.

### 2.7.1 Spherical Geodesy and the Haversine Formulation
Because the Earth is an oblate spheroid, planar Euclidean distance calculations ($d = \sqrt{\Delta x^2 + \Delta y^2}$) introduce substantial distortion when applied to geographic coordinates (latitude and longitude). To compute accurate surface distance over the terrestrial sphere, the system implements the **Haversine Formula**:

Let the center of the safe zone be defined by coordinate centroid $(\phi_1, \lambda_1)$ and the smartphone's current position by $(\phi_2, \lambda_2)$, where $\phi$ represents latitude and $\lambda$ represents longitude in radians.

The spherical angular separation $\Delta\sigma$ is calculated as:

$$\Delta\phi = \phi_2 - \phi_1$$

$$\Delta\lambda = \lambda_2 - \lambda_1$$

$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1) \cdot \cos(\phi_2) \cdot \sin^2\left(\frac{\Delta\lambda}{2}\right)$$

$$c = 2 \cdot \arctan2\left(\sqrt{a}, \sqrt{1 - a}\right)$$

The great-circle surface distance $d$ in meters is obtained by multiplying $c$ by the mean radius of the Earth $R \approx 6,371,000\text{ meters}$:

$$d = R \cdot c$$

The boundary evaluation condition is evaluated deterministically as:

$$\text{Status} = \begin{cases} \text{INSIDE SAFE ZONE}, & \text{if } d \le r_{\text{safe}} \\ \text{OUTSIDE SAFE ZONE (BREACH)}, & \text{if } d > r_{\text{safe}} \end{cases}$$

Where $r_{\text{safe}}$ is the user-configured geofence radius in meters (typically 50m, 100m, 250m, or 500m).

Table 2.4 synthesizes how these spatial and wireless concepts operate in unison.

**Table 2.4: Summary of Sensor and Wireless Communication Paradigms**
| Dimension | GPS Geofencing Module | BLE Proximity Module | Centralized Backend Module |
| :--- | :--- | :--- | :--- |
| **Sensor / Medium** | Onboard GNSS Receiver | 2.4 GHz BLE Antenna | HTTP Network Interface |
| **Input Telemetry** | Latitude, Longitude, Accuracy | Raw RSSI (dBm), MAC, Advertisements | JSON Payloads, REST Headers |
| **Mathematical Engine**| Haversine Spherical Formulation | Log-Distance Attenuation Classification| 60-Second De-Duplication Window |
| **Primary Output** | Spatial Boundary Breach Trigger | Qualitative Distance Classification | Persistent Mongoose ODM Storage |
| **Security Alert Type**| `safe_zone` Geofence Violation | `tracker_disconnected`, `weak_rssi` | Persistent Alert Log and Feed |

---

## 2.8 RESEARCH GAP
While extensive scholarly research exists in the separate domains of GNSS geodesy and indoor BLE localization, significant gaps remain at the intersection of practical, accessible asset protection:

1. **Isolation of Tracking Paradigms:** The majority of existing academic literature focuses exclusively on optimizing either outdoor GNSS positioning [4], [7] or indoor BLE fingerprinting/trilateration [1], [2], [10]. Few studies address the holistic software engineering challenge of integrating both paradigms into a cohesive, decoupled mobile-cloud application accessible to ordinary users.
2. **Technological Conflation in Consumer Applications:** Commercial marketing frequently misleads users into believing that mobile tracking applications track physical assets independently using GPS. There is an academic need for transparent software architectures that clearly decouple host device geolocation from peripheral radio proximity.
3. **Over-Reliance on Dense Fixed Infrastructure:** Many advanced indoor tracking frameworks surveyed in literature require pre-installed arrays of stationary BLE beacons, Wi-Fi fingerprint radio maps [9], [14], or multi-antenna Angle-of-Arrival (AoA) locator arrays [12]. Such systems are costly and stationary. Consumer personal asset protection demands a self-contained, mobile-centric architecture where the user's smartphone acts as the mobile scanning base station.
4. **Neglect of Full-Stack Architecture and Data Lifecycle:** Theoretical positioning papers rarely discuss persistent data modeling, asynchronous REST communication, offline fallback caching, or alert deduplication pipelines necessary for production deployments.

The **Smart Asset Protection and Hidden Tracking System** directly bridges these research gaps by designing, implementing, and validating an open, cross-platform architecture that combines mobile GPS geofencing, BLE beacon scanning, qualitative RSSI tiering, and cloud-based NoSQL persistence into a unified platform.

---

## 2.9 SUMMARY
This chapter reviewed existing literature and tracking technologies relevant to smart asset protection. The operational principles and physical limitations of satellite GNSS positioning and Bluetooth Low Energy were analyzed. The theoretical foundations of radio frequency propagation—specifically the Log-Distance Path Loss model—and the Haversine spherical distance formulation were derived. Finally, the chapter identified existing research gaps, highlighting the need for an integrated, open full-stack system that combines mobile GPS geofencing with local BLE proximity monitoring. The next chapter presents the requirement and system analysis for the proposed solution.
