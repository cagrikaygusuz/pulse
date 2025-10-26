import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isConnected = false;
  Timer? _connectivityTimer;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectivityStatus(result);
    });

    // Periodic connectivity check
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
    }
  }

  /// Update connectivity status
  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      
      if (kDebugMode) {
        debugPrint('Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}');
      }
    }
  }

  /// Check if device has internet access
  Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Wait for connectivity
  Future<void> waitForConnectivity({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return;
    
    return _connectivityController.stream
        .firstWhere((connected) => connected)
        .timeout(timeout);
  }

  /// Dispose resources
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}
