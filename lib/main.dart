import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAssetApp());
}

// Professional Blue, Navy & White Theme Colors
const Color primaryNavy = Color(0xFF0F2B5C);
const Color accentBlue = Color(0xFF1E60C6);
const Color softBlue = Color(0xFFE8EEF8);
const Color surfaceNavy = Color(0xFF1B365D);
const Color darkBg = Color(0xFF0A1324);

class SmartAssetApp extends StatefulWidget {
  const SmartAssetApp({super.key});

  @override
  State<SmartAssetApp> createState() => _SmartAssetAppState();
}

class _SmartAssetAppState extends State<SmartAssetApp> {
  bool isDarkMode = false;
  String customApiBase = 'http://127.0.0.1:5000';
  bool isLoggedIn = false;
  String currentUserName = 'Shivani Pabba';
  String currentUserEmail = 'shivani@sruniversity.ac.in';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      customApiBase = prefs.getString('apiBaseUrl') ?? 'http://127.0.0.1:5000';
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      currentUserName = prefs.getString('currentUserName') ?? 'Shivani Pabba';
      currentUserEmail = prefs.getString('currentUserEmail') ?? 'shivani@sruniversity.ac.in';
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _saveApiBase(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', url);
    setState(() {
      customApiBase = url;
    });
  }

  Future<void> _saveUserSession(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserName', name);
    await prefs.setString('currentUserEmail', email);
    setState(() {
      isLoggedIn = true;
      currentUserName = name;
      currentUserEmail = email;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      isLoggedIn = false;
      currentUserName = '';
      currentUserEmail = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Asset Protection',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentBlue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFF60A5FA),
          brightness: Brightness.dark,
          surface: const Color(0xFF131F33),
        ),
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: const Color(0xFF132238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF1E3A5F), width: 0.8),
          ),
        ),
      ),
      home: isLoggedIn
          ? HomePage(
              isDarkMode: isDarkMode,
              apiBaseUrl: customApiBase,
              currentUserName: currentUserName,
              currentUserEmail: currentUserEmail,
              onThemeChanged: (value) {
                setState(() => isDarkMode = value);
                _saveTheme(value);
              },
              onApiBaseChanged: _saveApiBase,
              onLogout: _handleLogout,
            )
          : AuthScreen(
              apiBaseUrl: customApiBase,
              isDarkMode: isDarkMode,
              onLoginSuccess: _saveUserSession,
            ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60C6), Color(0xFF0F2B5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: size * 0.8),
          Icon(Icons.bluetooth_searching, color: Colors.white, size: size * 0.45),
          Positioned(
            bottom: size * 0.08,
            child: Icon(
              Icons.location_on,
              color: Colors.amber.shade300,
              size: size * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}


// -------------------------------------------------------------
// USER AUTHENTICATION SCREEN (LOGIN / REGISTER)
// -------------------------------------------------------------

class AuthScreen extends StatefulWidget {
  final String apiBaseUrl;
  final bool isDarkMode;
  final Function(String name, String email) onLoginSuccess;

  const AuthScreen({
    super.key,
    required this.apiBaseUrl,
    required this.isDarkMode,
    required this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegistering = false;
  bool isLoading = false;
  bool obscurePassword = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController(text: 'shivani@sruniversity.ac.in');
  final TextEditingController passwordController = TextEditingController(text: '123456');
  final TextEditingController phoneController = TextEditingController();

  String errorMessage = '';

  String get effectiveApiBase {
    if (!kIsWeb && Platform.isAndroid) {
      if (widget.apiBaseUrl.contains('127.0.0.1') || widget.apiBaseUrl.contains('localhost')) {
        return widget.apiBaseUrl
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
    }
    return widget.apiBaseUrl;
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final fallbackName = email.contains('@') ? email.split('@').first : 'User';
    final name = isRegistering ? nameController.text.trim() : fallbackName;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please enter email and password.');
      return;
    }
    if (isRegistering && name.isEmpty) {
      setState(() => errorMessage = 'Please enter your full name.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final endpoint = isRegistering ? '/api/auth/register' : '/api/auth/login';
      final url = Uri.parse('$effectiveApiBase$endpoint');
      final body = isRegistering
          ? {
              'name': name,
              'email': email,
              'password': password,
              'phoneNumber': phoneController.text.trim(),
            }
          : {
              'email': email,
              'password': password,
            };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final returnedName = data['user']?['name'] ?? name;
        final returnedEmail = data['user']?['email'] ?? email;
        widget.onLoginSuccess(returnedName, returnedEmail);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['message'] ?? 'Authentication failed (${response.statusCode})';
        });
      }
    } catch (e) {
      // Offline fallback: if backend is starting or offline, log in locally with provided credentials
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note: Connecting in local demo mode ($e)'),
            backgroundColor: Colors.blueGrey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onLoginSuccess(name.isNotEmpty ? name : 'User', email);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _quickDemoLogin() {
    widget.onLoginSuccess('Shivani Pabba', 'shivani@sruniversity.ac.in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 72),
                      const SizedBox(height: 16),
                      Text(
                        'Smart Asset Protection',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SR University - CS&AI Capstone Project',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Sign In / Register Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? const Color(0xFF1E2D4A) : const Color(0xFFE8EEF8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  isRegistering = false;
                                  errorMessage = '';
                                }),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isRegistering ? primaryNavy : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !isRegistering ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  isRegistering = true;
                                  errorMessage = '';
                                }),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isRegistering ? primaryNavy : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isRegistering ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (isRegistering) ...[
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number (Optional)',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryNavy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  isRegistering ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Quick Demo Access Button
                      OutlinedButton.icon(
                        onPressed: _quickDemoLogin,
                        icon: const Icon(Icons.speed, size: 18),
                        label: const Text('Quick Demo Login (Shivani Pabba)'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final String apiBaseUrl;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onApiBaseChanged;
  final String currentUserName;
  final String currentUserEmail;
  final VoidCallback? onLogout;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.apiBaseUrl,
    required this.onThemeChanged,
    required this.onApiBaseChanged,
    this.currentUserName = 'Shivani Pabba',
    this.currentUserEmail = 'shivani@sruniversity.ac.in',
    this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Navigation
  int selectedIndex = 0;

  // Asset State
  final List<Map<String, dynamic>> assets = [];
  int? selectedAssetIndex;

  // Alerts State
  final List<Map<String, dynamic>> securityAlerts = [];
  final Set<String> _recentAlertKeys = {};

  // Location & Map State
  Position? currentPosition;
  LatLng? selectedMapPoint;
  bool isGettingLocation = false;
  String locationMessage = 'Location not fetched yet.';
  String placeName = 'Place name not available';
  final Geocoding geocoding = Geocoding();
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
  String bluetoothMessage = 'Bluetooth ready. Tap Scan to discover nearby BLE devices.';
  
  // Continuous RSSI Monitoring
  int? currentRssi;
  DateTime? lastRssiTimestamp;
  Timer? _rssiMonitorTimer;
  int weakRssiConsecutiveCount = 0;
  int rssiAlertThreshold = -80; // Configurable: Alert if weaker than -80 dBm

  // Simulation Mode (Transparently labeled for capstone presentations)
  bool isSimulationMode = false;
  Timer? _simulationTimer;
  int simulatedRssi = -65;

  // Categories & Safe Zone Radius options
  final List<String> categories = [
    'Electronics',
    'Jewellery',
    'Documents',
    'Vehicles',
    'Bags & Luggage',
    'Other',
  ];
  final List<int> radiusOptions = [20, 50, 100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupBleAdapterMonitoring();
  }

  @override
  void dispose() {
    _rssiMonitorTimer?.cancel();
    _simulationTimer?.cancel();
    _connectionSubscription?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }

  // User Identification & Scoped Keys
  String get _userStorageKey => widget.currentUserEmail.trim().toLowerCase();
  String get _userParam => Uri.encodeComponent(_userStorageKey);

  // API Endpoints
  String get effectiveApiBase {
    if (!kIsWeb && Platform.isAndroid) {
      if (widget.apiBaseUrl.contains('127.0.0.1') || widget.apiBaseUrl.contains('localhost')) {
        return widget.apiBaseUrl
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
    }
    return widget.apiBaseUrl;
  }

  String get baseAssetsUrl => '$effectiveApiBase/api/assets';
  String get baseAlertsUrl => '$effectiveApiBase/api/alerts';
  String get baseHistoryUrl => '$effectiveApiBase/api/history';

  String get assetsApiUrl => '$baseAssetsUrl?userId=$_userParam';
  String get alertsApiUrl => '$baseAlertsUrl?userId=$_userParam';
  String get historyApiUrl => '$baseHistoryUrl?userId=$_userParam';

  // -------------------------------------------------------------
  // INITIALIZATION & PERSISTENCE
  // -------------------------------------------------------------

  Future<void> _initializeData() async {
    await _loadSavedData();
    await _fetchAssetsFromServer();
    await _fetchAlertsFromServer();
    await _fetchHistoryFromServer();
    getCurrentLocation();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final userKey = _userStorageKey;
      String? savedAssets = prefs.getString('assets_$userKey');
      String? savedAlerts = prefs.getString('securityAlerts_json_$userKey');
      String? savedHistory = prefs.getString('locationHistory_$userKey');

      // Migrate legacy single-user storage if available for shivani
      if (savedAssets == null && userKey.contains('shivani')) {
        savedAssets = prefs.getString('assets');
        savedAlerts = prefs.getString('securityAlerts_json');
        savedHistory = prefs.getString('locationHistory');
      }

      final decodedAssets = savedAssets == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(savedAssets) as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      final decodedAlerts = savedAlerts == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(savedAlerts) as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      final decodedHistory = savedHistory == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(savedHistory) as List).map((item) {
              final entry = Map<String, dynamic>.from(item as Map);
              entry['time'] = DateTime.tryParse(entry['time']?.toString() ?? '') ?? DateTime.now();
              entry['latitude'] = (entry['latitude'] as num?)?.toDouble() ?? 0.0;
              entry['longitude'] = (entry['longitude'] as num?)?.toDouble() ?? 0.0;
              return entry;
            }).toList();

      if (kIsWeb && decodedAssets.isEmpty) {
        decodedAssets.addAll([
          {
            '_id': 'demo_asset_1',
            'name': 'Gold Ring',
            'category': 'Jewellery',
            'safeName': 'Home Safe Zone',
            'latitude': 18.086033,
            'longitude': 79.599920,
            'radius': 50,
            'trackerId': 'DC:8D:95:0A:E6:FF',
            'trackerName': 'Amazon Basics Aero Tag',
            'trackerStatus': 'connected',
            'lastRssi': -65,
            'movementLatitude': 18.086033,
            'movementLongitude': 79.599920,
            'isOutside': false,
          },
          {
            '_id': 'demo_asset_2',
            'name': 'College Bag & Laptop',
            'category': 'Bags & Luggage',
            'safeName': 'SR University Campus',
            'latitude': 18.086033,
            'longitude': 79.599920,
            'radius': 100,
            'trackerId': null,
            'trackerName': null,
            'trackerStatus': 'unpaired',
            'lastRssi': null,
            'movementLatitude': 18.086033,
            'movementLongitude': 79.599920,
            'isOutside': false,
          },
        ]);
      }

      if (kIsWeb && decodedAlerts.isEmpty) {
        decodedAlerts.addAll([
          {
            'title': 'System Active',
            'assetName': 'System',
            'description': 'Smart Asset Protection Web Evaluation Mode activated.',
            'alertType': 'system',
            'severity': 'info',
            'isRead': false,
            'timestamp': DateTime.now().toIso8601String(),
          },
          {
            'title': 'BLE Tracker Linked',
            'assetName': 'Gold Ring',
            'description': 'Aero Tag proximity signal verified (-65 dBm).',
            'alertType': 'tracker_connected',
            'severity': 'info',
            'isRead': false,
            'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          },
        ]);
      }

      if (!mounted) return;
      setState(() {
        assets
          ..clear()
          ..addAll(decodedAssets);

        securityAlerts
          ..clear()
          ..addAll(decodedAlerts);

        locationHistory
          ..clear()
          ..addAll(decodedHistory);

        selectedAssetIndex = assets.isEmpty ? null : 0;
      });
    } catch (e) {
      debugPrint('Error loading saved app data: $e');
    }
  }

  Future<void> _saveAppData() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _userStorageKey;
    final historyToSave = locationHistory.map((entry) {
      return {
        ...entry,
        'time': (entry['time'] is DateTime)
            ? (entry['time'] as DateTime).toIso8601String()
            : DateTime.now().toIso8601String(),
      };
    }).toList();

    await prefs.setString('assets_$userKey', jsonEncode(assets));
    await prefs.setString('securityAlerts_json_$userKey', jsonEncode(securityAlerts));
    await prefs.setString('locationHistory_$userKey', jsonEncode(historyToSave));
  }

  // -------------------------------------------------------------
  // BACKEND SYNCHRONIZATION
  // -------------------------------------------------------------

  Future<void> _fetchAssetsFromServer() async {
    if (kIsWeb && !effectiveApiBase.startsWith('https://')) return;
    try {
      final response = await http
          .get(Uri.parse(assetsApiUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final serverAssets = jsonDecode(response.body) as List;
      final oldAssetsById = <String, Map<String, dynamic>>{
        for (final item in assets)
          if (item['_id'] != null) item['_id'].toString(): item,
      };

      final loadedAssets = serverAssets.map((item) {
        final data = Map<String, dynamic>.from(item as Map);
        final id = data['_id']?.toString();
        final oldAsset = id == null ? null : oldAssetsById[id];
        final latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        final longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;

        return <String, dynamic>{
          '_id': id,
          'name': data['name'] ?? 'Unnamed Asset',
          'category': data['category'] ?? 'Other',
          'safeName': data['safeLocation'] ?? '',
          'latitude': latitude,
          'longitude': longitude,
          'radius': (data['radius'] as num?)?.toInt() ?? 100,
          'trackerId': data['trackerId'] ?? oldAsset?['trackerId'],
          'trackerName': data['trackerName'] ?? oldAsset?['trackerName'],
          'trackerStatus': data['trackerStatus'] ?? oldAsset?['trackerStatus'] ?? 'unpaired',
          'lastRssi': data['lastRssi'] ?? oldAsset?['lastRssi'],
          'movementLatitude': oldAsset?['movementLatitude'] ?? latitude,
          'movementLongitude': oldAsset?['movementLongitude'] ?? longitude,
          'isOutside': oldAsset?['isOutside'] ?? false,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        assets
          ..clear()
          ..addAll(loadedAssets);
        selectedAssetIndex = assets.isEmpty ? null : 0;
      });
      await _saveAppData();
    } catch (e) {
      debugPrint('Backend assets fetch offline: $e');
    }
  }

  Future<Map<String, dynamic>> _saveAssetToServer(
    Map<String, dynamic> asset, {
    String? id,
  }) async {
    final payload = {
      'name': asset['name'],
      'category': asset['category'],
      'description': asset['description'] ?? '',
      'latitude': asset['latitude'],
      'longitude': asset['longitude'],
      'safeLocation': asset['safeName'],
      'radius': asset['radius'],
      'trackerId': asset['trackerId'],
      'trackerName': asset['trackerName'],
      'trackerStatus': asset['trackerStatus'] ?? 'unpaired',
      'lastRssi': asset['lastRssi'],
      'userId': widget.currentUserEmail.trim().toLowerCase(),
    };

    final uri = id == null ? Uri.parse(baseAssetsUrl) : Uri.parse('$baseAssetsUrl/$id');

    final response = id == null
        ? await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          ).timeout(const Duration(seconds: 5))
        : await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server returned ${response.statusCode}: ${response.body}');
    }

    final result = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final savedAsset = result['asset'];
    if (savedAsset is! Map) {
      throw Exception('The backend response did not contain an asset.');
    }
    return Map<String, dynamic>.from(savedAsset);
  }

  Future<void> _deleteAssetFromServer(String id) async {
    await http
        .delete(Uri.parse('$baseAssetsUrl/$id'))
        .timeout(const Duration(seconds: 5));
  }

  Future<void> _fetchAlertsFromServer() async {
    if (kIsWeb && !effectiveApiBase.startsWith('https://')) return;
    try {
      final response = await http
          .get(Uri.parse(alertsApiUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final serverAlerts = (jsonDecode(response.body) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (!mounted) return;
        setState(() {
          securityAlerts
            ..clear()
            ..addAll(serverAlerts);
        });
        await _saveAppData();
      }
    } catch (e) {
      debugPrint('Backend alerts fetch offline: $e');
    }
  }

  Future<void> _fetchHistoryFromServer() async {
    if (kIsWeb && !effectiveApiBase.startsWith('https://')) return;
    try {
      final response = await http
          .get(Uri.parse(historyApiUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final serverHistory = (jsonDecode(response.body) as List).map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          m['time'] = DateTime.tryParse(m['timestamp']?.toString() ?? '') ?? DateTime.now();
          return m;
        }).toList();
        if (!mounted) return;
        setState(() {
          locationHistory
            ..clear()
            ..addAll(serverHistory);
        });
        await _saveAppData();
      }
    } catch (e) {
      debugPrint('Backend history fetch offline: $e');
    }
  }

  // -------------------------------------------------------------
  // SECURITY ALERTS SYSTEM (With De-duplication)
  // -------------------------------------------------------------

  void triggerSecurityAlert({
    required String title,
    required String description,
    required String alertType,
    String assetName = 'System',
    String? assetId,
    String severity = 'medium',
  }) {
    // Avoid duplicate alerts within 45 seconds
    final deDupKey = '$title:$assetName';
    if (_recentAlertKeys.contains(deDupKey)) {
      return;
    }
    _recentAlertKeys.add(deDupKey);
    Timer(const Duration(seconds: 45), () {
      _recentAlertKeys.remove(deDupKey);
    });

    final now = DateTime.now();
    final newAlert = <String, dynamic>{
      'title': title,
      'assetName': assetName,
      'assetId': assetId,
      'description': description,
      'alertType': alertType,
      'severity': severity,
      'userId': widget.currentUserEmail.trim().toLowerCase(),
      'isRead': false,
      'timestamp': now.toIso8601String(),
    };

    setState(() {
      securityAlerts.insert(0, newAlert);
      if (securityAlerts.length > 50) {
        securityAlerts.removeLast();
      }
    });
    _saveAppData();

    // Async post to backend
    http
        .post(
          Uri.parse(baseAlertsUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newAlert),
        )
        .catchError((_) => http.Response('', 500));
  }

  void markAlertAsRead(int index) {
    setState(() {
      securityAlerts[index]['isRead'] = true;
    });
    _saveAppData();

    final id = securityAlerts[index]['_id'];
    if (id != null) {
      http.patch(Uri.parse('$baseAlertsUrl/$id/read')).catchError((_) => http.Response('', 500));
    }
  }

  void clearAllAlerts() {
    setState(() {
      securityAlerts.clear();
    });
    _saveAppData();
    http.delete(Uri.parse(alertsApiUrl)).catchError((_) => http.Response('', 500));
  }

  // -------------------------------------------------------------
  // LOCATION & GEOFENCING LOGIC
  // -------------------------------------------------------------

  Future<Position> fetchLocation() async {
    if (kIsWeb) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        ).timeout(const Duration(seconds: 4));
      } catch (_) {
        return Position(
          latitude: 18.086033,
          longitude: 79.599920,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }
    }

    // 1. Verify device location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location Services (GPS) are turned off. Please turn ON GPS in your phone settings.');
      }
    }

    // 2. Check and request runtime location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied. Please allow location access in phone settings.');
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('Location permission permanently denied. Please allow location in App Settings.');
    }

    // 3. Try to acquire fresh real-time position with high accuracy
    // Allow up to 12 seconds so the smartphone GNSS/satellite hardware can compute an accurate fix
    try {
      final freshPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return freshPos;
    } catch (e) {
      // 4. If high accuracy times out (e.g., inside a building where direct satellite view is obstructed),
      // try medium/balanced accuracy which uses Wi-Fi and cell tower positioning
      try {
        final networkPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        return networkPos;
      } catch (e2) {
        // 5. If medium also times out, check if device has a RECENT last known location (within last 30 minutes)
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            final age = DateTime.now().difference(lastKnown.timestamp);
            if (age.inMinutes < 30) {
              return lastKnown;
            }
          }
        } catch (_) {}

        throw Exception('Could not acquire current GPS fix. Please ensure location is enabled with High Accuracy and test near a window or outdoors.');
      }
    }
  }

  Future<String> getPlaceName(double latitude, double longitude) async {
    if (kIsWeb) return 'SR University Campus, Warangal';
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return 'Place name not available';
      final place = placemarks.first;
      final parts = <String>[
        if ((place.name ?? '').isNotEmpty && place.name != place.street) place.name!,
        if ((place.street ?? '').isNotEmpty) place.street!,
        if ((place.subLocality ?? '').isNotEmpty && place.subLocality != place.street) place.subLocality!,
        if ((place.locality ?? '').isNotEmpty) place.locality!,
        if ((place.subAdministrativeArea ?? '').isNotEmpty && place.subAdministrativeArea != place.locality)
          place.subAdministrativeArea!,
        if ((place.administrativeArea ?? '').isNotEmpty) place.administrativeArea!,
        if ((place.country ?? '').isNotEmpty) place.country!,
      ];
      final uniqueParts = parts.toSet().toList();
      return uniqueParts.isEmpty ? 'Place name not available' : uniqueParts.join(', ');
    } catch (_) {
      return 'Place name unavailable';
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
      locationMessage = 'Acquiring GPS fix...';
    });

    try {
      final position = await fetchLocation();
      if (!mounted) return;
      setState(() {
        currentPosition = position;
        locationMessage = 'Resolving place name...';
      });

      final name = await getPlaceName(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        placeName = name;
        locationMessage = 'GPS fix acquired.';
        isGettingLocation = false;
      });

      if (selectedIndex == 3) {
        mapController.move(LatLng(position.latitude, position.longitude), 15);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationMessage = e.toString().replaceFirst('Exception: ', '');
        isGettingLocation = false;
      });
    }
  }

  double assetDistance(Map<String, dynamic> asset) {
    final currentLat = (asset['movementLatitude'] as num?)?.toDouble() ?? 0.0;
    final currentLng = (asset['movementLongitude'] as num?)?.toDouble() ?? 0.0;
    final safeLat = (asset['latitude'] as num?)?.toDouble() ?? 0.0;
    final safeLng = (asset['longitude'] as num?)?.toDouble() ?? 0.0;
    return Geolocator.distanceBetween(currentLat, currentLng, safeLat, safeLng);
  }

  String getSafeStatus(Map<String, dynamic> asset) {
    final distance = assetDistance(asset);
    final radius = (asset['radius'] as num?)?.toDouble() ?? 100.0;
    return distance <= radius ? 'Inside Safe Zone' : 'Outside Safe Zone';
  }

  Color getSafeColor(Map<String, dynamic> asset) {
    return getSafeStatus(asset) == 'Inside Safe Zone' ? Colors.green : Colors.red;
  }

  void addLocationHistoryRecord(Map<String, dynamic> asset, {String type = 'gps'}) {
    final record = {
      'assetName': asset['name'],
      'safeName': asset['safeName'],
      'latitude': (asset['movementLatitude'] as num).toDouble(),
      'longitude': (asset['movementLongitude'] as num).toDouble(),
      'status': getSafeStatus(asset),
      'historyType': type,
      'rssi': currentRssi,
      'userId': widget.currentUserEmail.trim().toLowerCase(),
      'time': DateTime.now(),
    };

    setState(() {
      locationHistory.insert(0, record);
      if (locationHistory.length > 100) {
        locationHistory.removeLast();
      }
    });
    _saveAppData();

    // Async post to backend
    http
        .post(
          Uri.parse(baseHistoryUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...record,
            'time': (record['time'] as DateTime).toIso8601String(),
          }),
        )
        .catchError((_) => http.Response('', 500));
  }

  void moveSelectedAsset() {
    if (assets.isEmpty || selectedAssetIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an asset to move.')),
      );
      return;
    }
    if (selectedMapPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap on the map first to pin a new position.')),
      );
      return;
    }

    final asset = assets[selectedAssetIndex!];
    final wasOutside = asset['isOutside'] == true;
    final newDistance = Geolocator.distanceBetween(
      selectedMapPoint!.latitude,
      selectedMapPoint!.longitude,
      (asset['latitude'] as num).toDouble(),
      (asset['longitude'] as num).toDouble(),
    );
    final isOutside = newDistance > (asset['radius'] as num).toDouble();

    setState(() {
      asset['movementLatitude'] = selectedMapPoint!.latitude;
      asset['movementLongitude'] = selectedMapPoint!.longitude;
      asset['isOutside'] = isOutside;
      addLocationHistoryRecord(asset, type: 'geofence');

      if (isOutside && !wasOutside) {
        triggerSecurityAlert(
          title: 'Asset Outside Safe Zone',
          description: '${asset['name']} has moved ${newDistance.toInt()}m from ${asset['safeName']}.',
          alertType: 'safe_zone',
          assetName: asset['name'],
          severity: 'high',
        );
      } else if (!isOutside && wasOutside) {
        triggerSecurityAlert(
          title: 'Asset Returned to Safe Zone',
          description: '${asset['name']} is back safely within ${asset['safeName']}.',
          alertType: 'safe_zone',
          assetName: asset['name'],
          severity: 'low',
        );
      }
      selectedMapPoint = null;
    });

    _saveAppData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOutside
              ? '${asset['name']} is OUTSIDE safe zone (${newDistance.toInt()}m)!'
              : '${asset['name']} is INSIDE safe zone (${newDistance.toInt()}m).',
        ),
        backgroundColor: isOutside ? Colors.red : Colors.green,
      ),
    );
  }

  // -------------------------------------------------------------
  // BLUETOOTH LOW ENERGY (BLE) TRACKER INTEGRATION
  // -------------------------------------------------------------

  void _setupBleAdapterMonitoring() {
    if (kIsWeb) return;
    try {
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.off && mounted) {
          setState(() {
            bluetoothMessage = 'Bluetooth is OFF. Please enable Bluetooth on your phone.';
            trackerConnected = false;
            connectedBleDevice = null;
          });
        }
      });

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            discoveredDevices = results;
          });
        }
      });
    } catch (_) {}
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (kIsWeb) return true;
    try {
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      await Permission.locationWhenInUse.request();

      if (scanStatus.isGranted && connectStatus.isGranted) {
        return true;
      }
      if (mounted) {
        setState(() {
          bluetoothMessage = 'Bluetooth permissions required. Please allow in Settings.';
        });
      }
      return false;
    } catch (e) {
      if (mounted) {
        setState(() {
          bluetoothMessage = 'Permission request error: $e';
        });
      }
      return false;
    }
  }

  Future<void> _startBleScan() async {
    if (isBleScanning) return;
    if (kIsWeb) {
      setState(() {
        bluetoothMessage = 'BLE hardware scan requires an Android phone. Use Simulation Mode on Web.';
      });
      return;
    }

    final granted = await _requestBluetoothPermissions();
    if (!granted) return;

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        if (mounted) {
          setState(() {
            bluetoothMessage = 'Bluetooth Low Energy is not supported on this hardware/emulator.';
          });
        }
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (mounted) {
          setState(() {
            bluetoothMessage = 'Bluetooth adapter is OFF. Turn ON Bluetooth to scan.';
          });
        }
        return;
      }

      setState(() {
        isBleScanning = true;
        discoveredDevices.clear();
        bluetoothMessage = 'Scanning for nearby BLE trackers (10s)...';
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          isBleScanning = false;
          bluetoothMessage = discoveredDevices.isEmpty
              ? 'Scan complete. No BLE devices found nearby.'
              : 'Scan complete. Discovered ${discoveredDevices.length} devices.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isBleScanning = false;
          bluetoothMessage = 'Bluetooth scan failed: $e';
        });
      }
    }
  }

  Future<void> _connectBleDevice(BluetoothDevice device) async {
    setState(() {
      bluetoothMessage = 'Connecting to ${device.platformName.isEmpty ? device.remoteId.str : device.platformName}...';
    });

    try {
      // Connect with 12s timeout
      await device.connect(
        timeout: const Duration(seconds: 12),
        license: License.nonprofit,
      );

      // Listen to connection state changes
      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        _handleConnectionStateChange(device, state);
      });

      // Discover GATT services
      List<BluetoothService> services = [];
      try {
        services = await device.discoverServices();
      } catch (e) {
        debugPrint('GATT discovery note: $e');
      }

      // Initial RSSI read
      int initialRssi = -60;
      try {
        initialRssi = await device.readRssi();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        connectedBleDevice = device;
        trackerConnected = true;
        discoveredServices = services;
        currentRssi = initialRssi;
        lastRssiTimestamp = DateTime.now();
        bluetoothMessage = 'Connected to ${device.platformName.isEmpty ? device.remoteId.str : device.platformName} (${services.length} GATT services discovered).';
      });

      // Start continuous RSSI polling
      _startRssiMonitoring(device);

      // Auto-update linked asset if an asset is selected
      _updateLinkedAssetTrackerInfo(
        trackerId: device.remoteId.str,
        trackerName: device.platformName.isEmpty ? 'BLE Tracker' : device.platformName,
        status: 'connected',
        rssi: initialRssi,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        trackerConnected = false;
        connectedBleDevice = null;
        bluetoothMessage = 'Connection failed: $e. Note: Some commercial tags (AirTag, AeroTag) use proprietary closed networks and block direct GATT connection.';
      });
      triggerSecurityAlert(
        title: 'Bluetooth Connection Failed',
        description: 'Unable to establish GATT connection with ${device.platformName.isEmpty ? device.remoteId.str : device.platformName}.',
        alertType: 'tracker_not_detected',
        severity: 'medium',
      );
    }
  }

  void _handleConnectionStateChange(BluetoothDevice device, BluetoothConnectionState state) {
    if (!mounted) return;

    if (state == BluetoothConnectionState.disconnected) {
      _stopRssiMonitoring();
      setState(() {
        trackerConnected = false;
        connectedBleDevice = null;
        bluetoothMessage = 'Tracker disconnected from phone.';
        currentRssi = null;
      });

      _updateLinkedAssetTrackerInfo(status: 'disconnected');

      triggerSecurityAlert(
        title: 'Bluetooth Tracker Disconnected',
        description: 'Connection lost with tracker ${device.platformName.isEmpty ? device.remoteId.str : device.platformName}. Check tracker proximity.',
        alertType: 'tracker_disconnected',
        severity: 'critical',
      );
    } else if (state == BluetoothConnectionState.connected) {
      setState(() {
        trackerConnected = true;
      });
    }
  }

  Future<void> _disconnectBleDevice() async {
    _stopRssiMonitoring();
    final device = connectedBleDevice;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (e) {
        debugPrint('BLE disconnect error: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      connectedBleDevice = null;
      trackerConnected = false;
      discoveredServices.clear();
      currentRssi = null;
      bluetoothMessage = 'Bluetooth tracker disconnected cleanly.';
    });

    _updateLinkedAssetTrackerInfo(status: 'disconnected');
  }

  void _startRssiMonitoring(BluetoothDevice device) {
    _stopRssiMonitoring();
    weakRssiConsecutiveCount = 0;

    _rssiMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!trackerConnected || connectedBleDevice == null) {
        timer.cancel();
        return;
      }

      try {
        final rssi = await device.readRssi();
        if (!mounted) return;

        setState(() {
          currentRssi = rssi;
          lastRssiTimestamp = DateTime.now();
        });

        // Check for continuous weak signal
        if (rssi < rssiAlertThreshold) {
          weakRssiConsecutiveCount++;
          if (weakRssiConsecutiveCount >= 2) {
            triggerSecurityAlert(
              title: 'Bluetooth RSSI Weak',
              description: 'Tracker signal is weak ($rssi dBm < $rssiAlertThreshold dBm). Asset may be moving out of Bluetooth range.',
              alertType: 'weak_rssi',
              severity: 'high',
            );
          }
        } else {
          weakRssiConsecutiveCount = 0;
        }

        _updateLinkedAssetTrackerInfo(rssi: rssi);
      } catch (e) {
        debugPrint('Error polling RSSI: $e');
      }
    });
  }

  void _stopRssiMonitoring() {
    _rssiMonitorTimer?.cancel();
    _rssiMonitorTimer = null;
  }

  void _updateLinkedAssetTrackerInfo({
    String? trackerId,
    String? trackerName,
    String? status,
    int? rssi,
  }) {
    if (selectedAssetIndex != null && selectedAssetIndex! < assets.length) {
      final asset = assets[selectedAssetIndex!];
      setState(() {
        if (trackerId != null) asset['trackerId'] = trackerId;
        if (trackerName != null) asset['trackerName'] = trackerName;
        if (status != null) asset['trackerStatus'] = status;
        if (rssi != null) asset['lastRssi'] = rssi;
      });
      _saveAppData();

      final id = asset['_id'];
      if (id != null) {
        http
            .patch(
              Uri.parse('$baseAssetsUrl/$id/tracker'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'trackerId': asset['trackerId'],
                'trackerName': asset['trackerName'],
                'trackerStatus': asset['trackerStatus'],
                'lastRssi': asset['lastRssi'],
              }),
            )
            .catchError((_) => http.Response('', 500));
      }
    }
  }

  // -------------------------------------------------------------
  // SIMULATION MODE (For Evaluation & Demo Purposes)
  // -------------------------------------------------------------

  void _toggleSimulationMode(bool enabled) {
    setState(() {
      isSimulationMode = enabled;
      if (enabled) {
        trackerConnected = true;
        simulatedRssi = -60;
        currentRssi = simulatedRssi;
        lastRssiTimestamp = DateTime.now();
        bluetoothMessage = 'Simulation Mode Active: Simulating compatible BLE tracker.';
        _startSimulationTicker();
      } else {
        _simulationTimer?.cancel();
        if (connectedBleDevice == null) {
          trackerConnected = false;
          currentRssi = null;
          bluetoothMessage = 'Simulation mode disabled.';
        }
      }
    });
  }

  void _startSimulationTicker() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!isSimulationMode) {
        timer.cancel();
        return;
      }
      setState(() {
        lastRssiTimestamp = DateTime.now();
      });
    });
  }

  void _simulateSignalDrop() {
    if (!isSimulationMode) return;
    setState(() {
      simulatedRssi = -88;
      currentRssi = -88;
      lastRssiTimestamp = DateTime.now();
    });
    triggerSecurityAlert(
      title: 'Bluetooth RSSI Weak (Simulated)',
      description: 'Simulated tracker signal dropped to -88 dBm (Weak). Proximity threshold exceeded.',
      alertType: 'weak_rssi',
      severity: 'high',
    );
  }

  void _simulateDisconnection() {
    if (!isSimulationMode) return;
    setState(() {
      trackerConnected = false;
      currentRssi = null;
      bluetoothMessage = 'Simulated tracker out of range / disconnected.';
    });
    triggerSecurityAlert(
      title: 'Bluetooth Tracker Disconnected (Simulated)',
      description: 'Simulated tracker has disconnected. Out of Bluetooth proximity.',
      alertType: 'tracker_disconnected',
      severity: 'critical',
    );
  }

  void _simulateRestore() {
    if (!isSimulationMode) return;
    setState(() {
      trackerConnected = true;
      simulatedRssi = -55;
      currentRssi = -55;
      lastRssiTimestamp = DateTime.now();
      bluetoothMessage = 'Simulated tracker reconnected with Strong signal.';
    });
  }

  // -------------------------------------------------------------
  // RSSI SIGNAL CLASSIFIER & HELPERS
  // -------------------------------------------------------------

  String getRssiCategory(int? rssi) {
    if (rssi == null || !trackerConnected) return 'No Signal';
    if (rssi >= -60) return 'Strong Signal';
    if (rssi >= -80) return 'Medium Signal';
    if (rssi >= -95) return 'Weak Signal';
    return 'Critical / Out of Range';
  }

  Color getRssiColor(int? rssi) {
    if (rssi == null || !trackerConnected) return Colors.grey;
    if (rssi >= -60) return const Color(0xFF16A34A); // Green
    if (rssi >= -80) return const Color(0xFFD97706); // Amber
    return const Color(0xFFDC2626); // Red
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_rounded;
      case 'Jewellery':
        return Icons.diamond_rounded;
      case 'Documents':
        return Icons.description_rounded;
      case 'Vehicles':
        return Icons.directions_car_rounded;
      case 'Bags & Luggage':
        return Icons.luggage_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  // -------------------------------------------------------------
  // ASSET REGISTRATION & EDIT DIALOG
  // -------------------------------------------------------------

  Future<void> showAssetDialog({int? index}) async {
    final editing = index != null;
    final oldAsset = editing ? assets[index] : null;

    final nameController = TextEditingController(text: oldAsset?['name'] ?? '');
    final safeNameController = TextEditingController(text: oldAsset?['safeName'] ?? '');
    final latitudeController = TextEditingController(
      text: oldAsset?['latitude'] != null ? oldAsset!['latitude'].toString() : '',
    );
    final longitudeController = TextEditingController(
      text: oldAsset?['longitude'] != null ? oldAsset!['longitude'].toString() : '',
    );
    String category = oldAsset?['category'] ?? categories[0];
    int radius = oldAsset?['radius'] ?? 100;
    String? linkedTrackerId = oldAsset?['trackerId'];
    String? linkedTrackerName = oldAsset?['trackerName'];
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isFetchingGps = false;
            String? gpsStatusMessage;

            Future<void> useCurrentLocation() async {
              setDialogState(() {
                isFetchingGps = true;
                gpsStatusMessage = 'Acquiring GPS fix...';
                errorMessage = null;
              });
              try {
                final pos = await fetchLocation();
                setDialogState(() {
                  latitudeController.text = pos.latitude.toStringAsFixed(6);
                  longitudeController.text = pos.longitude.toStringAsFixed(6);
                  isFetchingGps = false;
                  gpsStatusMessage = 'Live GPS Acquired: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
                  errorMessage = null;
                });

                setState(() {
                  currentPosition = pos;
                });

                if (safeNameController.text.trim().isEmpty) {
                  try {
                    final place = await getPlaceName(pos.latitude, pos.longitude);
                    if (place.isNotEmpty && place != 'Place name unavailable' && place != 'Place name not available') {
                      setDialogState(() {
                        safeNameController.text = place;
                      });
                    } else {
                      setDialogState(() {
                        safeNameController.text = 'My Current Location';
                      });
                    }
                  } catch (_) {
                    setDialogState(() {
                      safeNameController.text = 'My Current Location';
                    });
                  }
                }
              } catch (e) {
                setDialogState(() {
                  isFetchingGps = false;
                  gpsStatusMessage = null;
                  errorMessage = e.toString().replaceFirst('Exception: ', '');
                });
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  Icon(editing ? Icons.edit_note : Icons.add_box, color: primaryNavy),
                  const SizedBox(width: 8),
                  Text(editing ? 'Edit Asset' : 'Register New Asset'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Asset Name *',
                          hintText: 'e.g. Laptop Bag, Office Keys, Drone',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((item) {
                          return DropdownMenuItem(value: item, child: Text(item));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => category = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SAFE ZONE GEOFENCE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: safeNameController,
                        decoration: const InputDecoration(
                          labelText: 'Safe Zone Name *',
                          hintText: 'e.g. Home, Office, Campus Lab',
                          prefixIcon: Icon(Icons.home_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isFetchingGps ? null : useCurrentLocation,
                          icon: isFetchingGps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(isFetchingGps
                              ? 'Acquiring GPS Fix...'
                              : 'Use Current Phone GPS Coordinates'),
                        ),
                      ),
                      if (gpsStatusMessage != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  gpsStatusMessage!,
                                  style: TextStyle(color: Colors.green.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: 'Safe Latitude',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: longitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: 'Safe Longitude',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: radius,
                        decoration: const InputDecoration(
                          labelText: 'Safe Zone Radius',
                          border: OutlineInputBorder(),
                        ),
                        items: radiusOptions.map((val) {
                          return DropdownMenuItem(value: val, child: Text('$val metres'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => radius = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'BLUETOOTH TRACKER PAIRING',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softBlue,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              linkedTrackerId != null
                                  ? 'Paired: ${linkedTrackerName ?? "Tracker"} ($linkedTrackerId)'
                                  : 'No tracker paired to this asset yet.',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            if (connectedBleDevice != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    linkedTrackerId = connectedBleDevice!.remoteId.str;
                                    linkedTrackerName = connectedBleDevice!.platformName.isNotEmpty
                                        ? connectedBleDevice!.platformName
                                        : 'BLE Tracker';
                                  });
                                },
                                icon: const Icon(Icons.link, size: 18),
                                label: Text('Pair Connected Tracker (${connectedBleDevice!.remoteId.str.substring(0, 8)}...)'),
                              )
                            else if (isSimulationMode)
                              ElevatedButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    linkedTrackerId = 'SIM-BLE-TRACKER-01';
                                    linkedTrackerName = 'Simulated BLE Beacon';
                                  });
                                },
                                icon: const Icon(Icons.link, size: 18),
                                label: const Text('Pair Simulated Tracker'),
                              )
                            else
                              const Text(
                                'Connect a BLE tracker in the Tracker tab to pair it here.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final safeName = safeNameController.text.trim();
                    final lat = double.tryParse(latitudeController.text);
                    final lng = double.tryParse(longitudeController.text);

                    if (name.isEmpty || safeName.isEmpty || lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
                      setDialogState(() {
                        errorMessage = 'Please provide valid asset name, safe name, and coordinates.';
                      });
                      return;
                    }

                    final assetData = <String, dynamic>{
                      'name': name,
                      'category': category,
                      'safeName': safeName,
                      'latitude': lat,
                      'longitude': lng,
                      'radius': radius,
                      'trackerId': linkedTrackerId,
                      'trackerName': linkedTrackerName,
                      'trackerStatus': linkedTrackerId != null ? 'connected' : 'unpaired',
                      'movementLatitude': oldAsset?['movementLatitude'] ?? lat,
                      'movementLongitude': oldAsset?['movementLongitude'] ?? lng,
                      'isOutside': oldAsset?['isOutside'] ?? false,
                    };

                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final String? existingId = (editing && oldAsset != null)
                          ? oldAsset['_id']?.toString()
                          : null;
                      final serverAsset = await _saveAssetToServer(
                        assetData,
                        id: existingId,
                      );
                      assetData['_id'] = serverAsset['_id']?.toString();

                      if (!mounted) return;
                      setState(() {
                        if (editing) {
                          assets[index] = assetData;
                        } else {
                          assets.add(assetData);
                          selectedAssetIndex = assets.length - 1;
                        }
                      });
                      await _saveAppData();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(editing ? 'Asset updated successfully.' : 'Asset registered and saved.'),
                            backgroundColor: primaryNavy,
                          ),
                        );
                      }
                    } catch (e) {
                      // Fallback: save locally in app storage (SharedPreferences)
                      if (!mounted) return;
                      setState(() {
                        if (editing) {
                          assets[index] = assetData;
                        } else {
                          assets.add(assetData);
                          selectedAssetIndex = assets.length - 1;
                        }
                      });
                      await _saveAppData();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(editing
                                ? 'Asset updated successfully (Saved locally).'
                                : 'Asset registered and saved successfully.'),
                            backgroundColor: primaryNavy,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(editing ? 'Update Asset' : 'Save Asset'),
                ),
              ],
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      safeNameController.dispose();
      latitudeController.dispose();
      longitudeController.dispose();
    });
  }

  void deleteAsset(int index) {
    final asset = assets[index];
    final name = asset['name'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Asset?'),
          content: Text('Are you sure you want to remove "$name"? All associated safe zone parameters will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final serverId = asset['_id']?.toString();
                if (serverId != null && serverId.isNotEmpty) {
                  try {
                    await _deleteAssetFromServer(serverId);
                  } catch (e) {
                    debugPrint('Delete backend error: $e');
                  }
                }

                if (!mounted) return;
                setState(() {
                  assets.removeAt(index);
                  if (assets.isEmpty) {
                    selectedAssetIndex = null;
                  } else if (selectedAssetIndex != null && selectedAssetIndex! >= assets.length) {
                    selectedAssetIndex = assets.length - 1;
                  }
                  locationHistory.removeWhere((entry) => entry['assetName'] == name);
                });
                _saveAppData();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // UI WIDGETS & SECTIONS
  // -------------------------------------------------------------

  Widget sectionHeader(String title, String subtitle, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // 1. DASHBOARD / HOME SCREEN
  Widget homeScreen() {
    final outsideCount = assets.where((a) => getSafeStatus(a) == 'Outside Safe Zone').length;
    final unreadAlertsCount = securityAlerts.where((a) => a['isRead'] == false).length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // App Hero Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2B5C), Color(0xFF1E60C6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryNavy.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 46),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Asset Protection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hidden Tracking & BLE Proximity System',
                          style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: trackerConnected ? Colors.green.shade600 : Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trackerConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trackerConnected ? 'BLE ACTIVE' : 'BLE IDLE',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Comprehensive security monitoring combining phone GPS safe-zones with continuous Bluetooth Low Energy RSSI beacon proximity.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
            ],
          ),
        ),
        if (unreadAlertsCount > 0) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => selectedIndex = 4),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$unreadAlertsCount unread security alert(s). Tap to inspect.',
                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),

        // Live Metric Cards
        Row(
          children: [
            Expanded(
              child: statCard(
                'Total Assets',
                assets.length.toString(),
                Icons.inventory_2_outlined,
                primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'Safe Zones',
                assets.length.toString(),
                Icons.shield_outlined,
                const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: statCard(
                'Phone GPS',
                currentPosition != null ? 'Acquired' : 'Pending',
                Icons.gps_fixed,
                const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'Outside Zones',
                outsideCount.toString(),
                Icons.warning_amber_rounded,
                outsideCount > 0 ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Active RSSI Monitor Quick View
        rssiMonitoringCard(compact: true),
        const SizedBox(height: 18),

        // Quick Action Buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showAssetDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Asset'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => selectedIndex = 2),
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Scan BLE'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Recent Registered Assets
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monitored Assets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy),
            ),
            TextButton(
              onPressed: () => setState(() => selectedIndex = 1),
              child: const Text('View All'),
            ),
          ],
        ),
        if (assets.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: Text('No assets added yet. Tap "Add Asset" to register your first protected item.'),
              ),
            ),
          ),
        ...assets.take(4).map((asset) {
          final isOutside = getSafeStatus(asset) == 'Outside Safe Zone';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: softBlue,
                child: Icon(categoryIcon(asset['category']), color: primaryNavy),
              ),
              title: Text(asset['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${asset['category']} • Safe: ${asset['safeName']} (${asset['radius']}m)'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOutside ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isOutside ? Colors.red.shade200 : Colors.green.shade200),
                ),
                child: Text(
                  isOutside ? 'OUTSIDE' : 'SECURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOutside ? Colors.red : Colors.green.shade700,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 26),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 2. ASSETS MANAGEMENT SCREEN
  Widget assetsScreen() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionHeader(
          'Protected Assets',
          'Manage belongings, safe-zone boundaries, and tracker pairings.',
          trailing: FilledButton.icon(
            onPressed: () => showAssetDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Asset'),
          ),
        ),
        if (assets.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No assets registered yet.', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Add your valuables to start geofencing and Bluetooth proximity tracking.'),
                  ],
                ),
              ),
            ),
          ),
        ...assets.asMap().entries.map((entry) {
          final index = entry.key;
          final asset = entry.value;
          final isOutside = getSafeStatus(asset) == 'Outside Safe Zone';
          final trackerName = asset['trackerName'] ?? 'No BLE Tracker Paired';
          final hasTracker = asset['trackerId'] != null;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: softBlue,
                        child: Icon(categoryIcon(asset['category']), color: primaryNavy, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset['name'],
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(asset['category'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              'Safe Zone: ${asset['safeName']} (Radius: ${asset['radius']}m)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') {
                            showAssetDialog(index: index);
                          } else if (val == 'delete') {
                            deleteAsset(index);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                          PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete')])),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasTracker ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                            size: 16,
                            color: hasTracker ? accentBlue : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trackerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasTracker ? primaryNavy : Colors.grey,
                              fontWeight: hasTracker ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutside ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isOutside ? Colors.red.shade200 : Colors.green.shade200),
                        ),
                        child: Text(
                          isOutside ? 'OUTSIDE SAFE ZONE' : 'INSIDE SAFE ZONE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOutside ? Colors.red : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // 3. BLUETOOTH TRACKER & RSSI MONITOR SCREEN
  Widget trackerScreen() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionHeader(
          'Bluetooth Tracker',
          'Scan, pair, and continuously monitor BLE tracker proximity.',
        ),

        // Simulation Mode Card (Evaluation Switch)
        Card(
          color: isSimulationMode ? const Color(0xFFFEF3C7) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: isSimulationMode ? Colors.amber.shade900 : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BLE Evaluation Simulation Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSimulationMode ? Colors.amber.shade900 : primaryNavy,
                        ),
                      ),
                      const Text(
                        'Allows testing signal attenuation & disconnection when physical BLE hardware is out of range.',
                        style: TextStyle(fontSize: 11.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isSimulationMode,
                  activeTrackColor: primaryNavy,
                  onChanged: _toggleSimulationMode,
                ),
              ],
            ),
          ),
        ),
        if (isSimulationMode) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SIMULATION CONTROLS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _simulateRestore,
                        icon: const Icon(Icons.signal_cellular_alt, size: 16, color: Colors.green),
                        label: const Text('Strong Signal (-55 dBm)'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _simulateSignalDrop,
                        icon: const Icon(Icons.signal_cellular_connected_no_internet_0_bar, size: 16, color: Colors.orange),
                        label: const Text('Weak Signal (-88 dBm)'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _simulateDisconnection,
                        icon: const Icon(Icons.link_off, size: 16, color: Colors.red),
                        label: const Text('Simulate Disconnect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),

        // Live RSSI Monitoring Card
        rssiMonitoringCard(),
        const SizedBox(height: 16),

        // Hardware Scan and Actions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          trackerConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                          color: trackerConnected ? Colors.green : primaryNavy,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          trackerConnected ? 'Tracker Connected' : 'No Tracker Connected',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    if (isBleScanning)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(bluetoothMessage, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isBleScanning ? null : _startBleScan,
                        icon: const Icon(Icons.search),
                        label: Text(isBleScanning ? 'Scanning...' : 'Scan BLE Devices'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: trackerConnected ? _disconnectBleDevice : null,
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('Disconnect'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // GATT Services Discovered Card (Displays if services exist)
        if (discoveredServices.isNotEmpty) ...[
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.account_tree_outlined, color: primaryNavy),
              title: Text('Discovered GATT Services (${discoveredServices.length})'),
              subtitle: const Text('Standard & vendor Bluetooth Low Energy profiles'),
              children: discoveredServices.map((service) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.settings_input_component, size: 18),
                  title: Text(service.serviceUuid.str),
                  subtitle: Text('${service.characteristics.length} characteristics found'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Discovered Devices List
        const Text(
          'NEARBY BLE PERIPHERALS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1, color: primaryNavy),
        ),
        const SizedBox(height: 8),
        if (discoveredDevices.isEmpty && !isBleScanning)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: Text('No BLE devices detected yet. Tap "Scan BLE Devices" with Bluetooth and GPS enabled.'),
              ),
            ),
          ),
        ...discoveredDevices.map((result) {
          final device = result.device;
          final name = device.platformName.isNotEmpty ? device.platformName : 'Unknown Peripheral';
          final isCurrent = connectedBleDevice?.remoteId == device.remoteId;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: softBlue,
                child: const Icon(Icons.bluetooth, color: primaryNavy, size: 20),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('MAC / ID: ${device.remoteId.str}\nSignal: ${result.rssi} dBm (${getRssiCategory(result.rssi)})'),
              isThreeLine: true,
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.green : primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: isCurrent ? null : () => _connectBleDevice(device),
                child: Text(isCurrent ? 'Connected' : 'Connect'),
              ),
            ),
          );
        }),
      ],
    );
  }

  // RSSI Gauge & Proximity Card
  Widget rssiMonitoringCard({bool compact = false}) {
    final category = getRssiCategory(currentRssi);
    final color = getRssiColor(currentRssi);
    final rssiValue = currentRssi != null ? '$currentRssi dBm' : '-- dBm';
    final timeStr = lastRssiTimestamp != null
        ? '${lastRssiTimestamp!.hour.toString().padLeft(2, '0')}:${lastRssiTimestamp!.minute.toString().padLeft(2, '0')}:${lastRssiTimestamp!.second.toString().padLeft(2, '0')}'
        : 'Not detected';

    // Proximity progress (normalize -100 dBm to -40 dBm into 0.0 -> 1.0)
    double progress = 0.0;
    if (currentRssi != null && trackerConnected) {
      progress = ((currentRssi! + 100) / 60.0).clamp(0.05, 1.0);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.radar, color: color, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Live RSSI Proximity Monitor',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  rssiValue,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  'Last ping: $timeStr',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Far / Weak (-100 dBm)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Near / Strong (-40 dBm)', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            if (!compact) ...[
              const Divider(height: 24),
              const Text(
                'Proximity Notice: Bluetooth RSSI indicates approximate radio signal attenuation, not exact metric distance. Physical walls, human bodies, and radio interference fluctuate signal strength.',
                style: TextStyle(fontSize: 11.5, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 4. GPS & GEOFENCING MAP SCREEN
  Widget locationScreen() {
    final center = currentPosition != null
        ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
        : const LatLng(17.3850, 78.4867);

    final markers = <Marker>[];

    // Phone GPS position marker
    if (currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          width: 48,
          height: 48,
          child: const Tooltip(
            message: 'Your Smartphone Current GPS',
            child: Icon(Icons.my_location, color: Color(0xFF2563EB), size: 36),
          ),
        ),
      );
    }

    // Asset position markers
    for (final asset in assets) {
      markers.add(
        Marker(
          point: LatLng(
            (asset['movementLatitude'] as num).toDouble(),
            (asset['movementLongitude'] as num).toDouble(),
          ),
          width: 50,
          height: 50,
          child: Tooltip(
            message: asset['name'],
            child: Icon(Icons.location_on, color: getSafeColor(asset), size: 40),
          ),
        ),
      );
    }

    // Pin marker for move test
    if (selectedMapPoint != null) {
      markers.add(
        Marker(
          point: selectedMapPoint!,
          width: 45,
          height: 45,
          child: const Icon(Icons.push_pin, color: Colors.deepOrange, size: 36),
        ),
      );
    }

    final circles = assets.map((asset) {
      return CircleMarker(
        point: LatLng(
          (asset['latitude'] as num).toDouble(),
          (asset['longitude'] as num).toDouble(),
        ),
        radius: (asset['radius'] as num).toDouble(),
        useRadiusInMeter: true,
        color: Colors.green.withValues(alpha: 0.15),
        borderColor: Colors.green.shade700,
        borderStrokeWidth: 2,
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionHeader(
          'Asset Geofence Map',
          'Inspect safe zones, monitor coordinates, and test movement.',
        ),

        // Asset Selector to Move
        if (assets.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                initialValue: selectedAssetIndex != null && selectedAssetIndex! < assets.length
                    ? selectedAssetIndex
                    : 0,
                decoration: const InputDecoration(
                  labelText: 'Selected Asset to Test Movement',
                  prefixIcon: Icon(Icons.inventory_2, color: primaryNavy),
                  border: OutlineInputBorder(),
                ),
                items: assets.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedAssetIndex = val);
                },
              ),
            ),
          ),
        const SizedBox(height: 12),

        // Interactive Map
        SizedBox(
          height: 380,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  setState(() {
                    selectedMapPoint = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smart_asset_protection_hiddentracking_system',
                ),
                CircleLayer(circles: circles),
                MarkerLayer(markers: markers),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Map Guide & Move Control
        if (selectedMapPoint != null)
          Card(
            color: const Color(0xFFFEF3C7),
            child: ListTile(
              leading: const Icon(Icons.push_pin, color: Colors.deepOrange),
              title: const Text('Pinned Test Coordinates', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${selectedMapPoint!.latitude.toStringAsFixed(6)}, ${selectedMapPoint!.longitude.toStringAsFixed(6)}'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => selectedMapPoint = null),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: (assets.isEmpty || selectedAssetIndex == null || selectedMapPoint == null)
                    ? null
                    : moveSelectedAsset,
                icon: const Icon(Icons.drive_file_move_outlined),
                label: const Text('Move Asset to Pin'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: isGettingLocation ? null : getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: Text(isGettingLocation ? 'Fixing...' : 'Get GPS'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current Phone GPS Details
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PHONE GPS STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryNavy)),
                const SizedBox(height: 8),
                Text(locationMessage, style: const TextStyle(fontSize: 13)),
                if (currentPosition != null) ...[
                  const SizedBox(height: 4),
                  Text('Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}', style: const TextStyle(fontSize: 12)),
                  Text('Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}', style: const TextStyle(fontSize: 12)),
                  Text('Place: $placeName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
                const Divider(height: 18),
                const Text(
                  'Architecture Note: Smartphone GPS tracks the phone location. Bluetooth RSSI monitors the physical tag attached to the protected asset.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 5. SECURITY ALERTS SCREEN
  Widget alertsScreen() {
    final unreadCount = securityAlerts.where((a) => a['isRead'] == false).length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionHeader(
          'Security Alerts',
          unreadCount > 0
              ? 'You have $unreadCount unread security notifications.'
              : 'Real-time alerts for safe-zone breaches, disconnects, and weak RSSI.',
          trailing: securityAlerts.isNotEmpty
              ? TextButton.icon(
                  onPressed: clearAllAlerts,
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Clear All'),
                )
              : null,
        ),
        if (securityAlerts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_none, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No security alerts recorded.', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Events such as safe-zone breaches and Bluetooth drops will appear here.'),
                  ],
                ),
              ),
            ),
          ),
        ...securityAlerts.asMap().entries.map((entry) {
          final index = entry.key;
          final alert = entry.value;
          final isRead = alert['isRead'] == true;
          final type = alert['alertType']?.toString() ?? 'system';
          final severity = alert['severity']?.toString() ?? 'medium';

          Color alertColor;
          IconData alertIcon;
          if (type == 'safe_zone') {
            alertColor = Colors.orange.shade800;
            alertIcon = Icons.location_off;
          } else if (type == 'tracker_disconnected') {
            alertColor = Colors.red.shade700;
            alertIcon = Icons.bluetooth_disabled;
          } else if (type == 'weak_rssi') {
            alertColor = Colors.amber.shade800;
            alertIcon = Icons.signal_cellular_connected_no_internet_0_bar;
          } else {
            alertColor = primaryNavy;
            alertIcon = Icons.info_outline;
          }

          final timeStr = alert['timestamp'] != null
              ? alert['timestamp'].toString().replaceAll('T', ' ').substring(0, 19)
              : '';

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isRead ? null : softBlue.withValues(alpha: 0.5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: alertColor.withValues(alpha: 0.15),
                child: Icon(alertIcon, color: alertColor),
              ),
              title: Text(
                alert['title'] ?? 'Security Alert',
                style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
              ),
              subtitle: Text('${alert['description']}\n$timeStr • Asset: ${alert['assetName'] ?? "General"} • Level: ${severity.toUpperCase()}'),
              isThreeLine: true,
              trailing: isRead
                  ? null
                  : IconButton(
                      tooltip: 'Mark as read',
                      icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                      onPressed: () => markAlertAsRead(index),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // 6. LOCATION & TRACKER HISTORY SCREEN
  Widget historyScreen() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        sectionHeader(
          'Location & Event History',
          'Audit trail of GPS movements, geofencing events, and tracker pings.',
          trailing: locationHistory.isNotEmpty
              ? TextButton.icon(
                  onPressed: () {
                    setState(() => locationHistory.clear());
                    _saveAppData();
                    http.delete(Uri.parse(historyApiUrl)).catchError((_) => http.Response('', 500));
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                )
              : null,
        ),
        if (locationHistory.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No history records yet.', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Move an asset on the map or record GPS pings to populate the history audit log.'),
                  ],
                ),
              ),
            ),
          ),
        ...locationHistory.map((entry) {
          final isOutside = entry['status'] == 'Outside Safe Zone';
          final time = entry['time'] is DateTime ? entry['time'] as DateTime : DateTime.now();

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                isOutside ? Icons.location_off : Icons.location_on,
                color: isOutside ? Colors.red : Colors.green,
              ),
              title: Text(
                entry['assetName']?.toString() ?? 'Asset Event',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Status: ${entry['status']}\n'
                'Safe Zone: ${entry['safeName'] ?? "N/A"}\n'
                'Lat: ${(entry['latitude'] as num?)?.toStringAsFixed(6)}, Lng: ${(entry['longitude'] as num?)?.toStringAsFixed(6)}\n'
                'Date: ${time.toLocal().toString().substring(0, 19)}',
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
    );
  }

  // 7. SETTINGS SCREEN
  Widget settingsScreen() {
    final serverUrlController = TextEditingController(text: widget.apiBaseUrl);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Center(child: AppLogo(size: 72)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Smart Asset Protection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy),
          ),
        ),
        const Center(
          child: Text(
            'B.Tech Capstone Demonstration Version 1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('User Profile', 'Signed in account details'),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: primaryNavy,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(widget.currentUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.currentUserEmail),
            trailing: FilledButton.tonalIcon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
              label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        sectionHeader('Settings & Configuration', 'Customize appearance and backend network parameters.'),

        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle high-contrast dark theme'),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ),
        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dns_outlined, color: primaryNavy),
                    SizedBox(width: 10),
                    Text('Backend Server API URL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Default is http://127.0.0.1:5000. When testing on a physical phone, set to your computer Wi-Fi IP (e.g. http://192.168.1.5:5000) or use "adb reverse tcp:5000 tcp:5000".',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serverUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    widget.onApiBaseChanged(serverUrlController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backend API URL updated.')),
                    );
                  },
                  child: const Text('Update Server URL'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, color: primaryNavy),
                    SizedBox(width: 10),
                    Text('RSSI Weak Signal Threshold', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Trigger warning when signal is weaker than: $rssiAlertThreshold dBm'),
                Slider(
                  value: rssiAlertThreshold.toDouble(),
                  min: -95,
                  max: -65,
                  divisions: 6,
                  label: '$rssiAlertThreshold dBm',
                  onChanged: (val) {
                    setState(() => rssiAlertThreshold = val.toInt());
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Architecture Summary'),
            subtitle: Text('Frontend: Flutter • Backend: Node.js Express • DB: MongoDB • Hardware: BLE Beacon & Phone GPS'),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // MAIN SCAFFOLD & NAVIGATION
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final unreadAlerts = securityAlerts.where((a) => a['isRead'] == false).length;

    final pages = [
      homeScreen(),
      assetsScreen(),
      trackerScreen(),
      locationScreen(),
      alertsScreen(),
      historyScreen(),
      settingsScreen(),
    ];

    final titles = [
      'Smart Asset Protection',
      'Protected Assets',
      'Bluetooth BLE Tracker',
      'Geofence & Movement Map',
      'Security Alerts',
      'Location & Event History',
      'Settings & Network',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppLogo(size: 38),
        ),
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => selectedIndex = 4),
            icon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text(unreadAlerts.toString()),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) {
          setState(() => selectedIndex = idx);
          if (idx == 3 && currentPosition == null && !isGettingLocation) {
            getCurrentLocation();
          }
        },
        indicatorColor: softBlue,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Assets',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bluetooth_outlined),
            selectedIcon: Icon(Icons.bluetooth),
            label: 'Tracker',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text(unreadAlerts.toString()),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
