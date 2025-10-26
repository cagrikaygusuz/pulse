import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import 'connectivity_service.dart';
import 'monitoring_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();
  final SessionRepositoryImpl _sessionRepository = SessionRepositoryImpl();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Current sync status
  SyncStatus get currentStatus => _syncStatusController.hasListener 
      ? _syncStatusController.stream.value 
      : SyncStatus.idle;

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected) {
        _startPeriodicSync();
      } else {
        _stopPeriodicSync();
      }
    });

    // Start periodic sync if connected
    if (_connectivityService.isConnected) {
      _startPeriodicSync();
    }
  }

  /// Start periodic sync
  void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _syncAllData(),
    );
  }

  /// Stop periodic sync
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sync all data
  Future<void> _syncAllData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        _syncStatusController.add(SyncStatus.idle);
        return;
      }

      // Sync projects
      await _syncProjects(userId);
      
      // Sync tasks
      await _syncTasks(userId);
      
      // Sync sessions
      await _syncSessions(userId);
      
      _syncStatusController.add(SyncStatus.completed);
      
      if (kDebugMode) {
        debugPrint('Sync completed successfully');
      }
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      await MonitoringService.logError(e, null, context: 'sync_all_data');
      
      if (kDebugMode) {
        debugPrint('Sync failed: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync projects
  Future<void> _syncProjects(String userId) async {
    try {
      // Get projects needing sync
      final pendingProjects = await _taskRepository.getPendingSyncProjects(userId);
      
      if (pendingProjects.isNotEmpty) {
        // Sync to remote
        await _taskRepository.syncPendingProjects(userId);
        
        if (kDebugMode) {
          debugPrint('Synced ${pendingProjects.length} projects');
        }
      }
    } catch (e) {
      await MonitoringService.logError(e, null, context: 'sync_projects');
    }
  }

  /// Sync tasks
  Future<void> _syncTasks(String userId) async {
    try {
      // Get tasks needing sync
      final pendingTasks = await _taskRepository.getPendingSyncTasks(userId);
      
      if (pendingTasks.isNotEmpty) {
        // Sync to remote
        await _taskRepository.syncPendingTasks(userId);
        
        if (kDebugMode) {
          debugPrint('Synced ${pendingTasks.length} tasks');
        }
      }
    } catch (e) {
      await MonitoringService.logError(e, null, context: 'sync_tasks');
    }
  }

  /// Sync sessions
  Future<void> _syncSessions(String userId) async {
    try {
      // Get sessions needing sync
      final pendingSessions = await _sessionRepository.getPendingSyncSessions(userId);
      
      if (pendingSessions.isNotEmpty) {
        // Sync to remote
        await _sessionRepository.syncPendingSessions(userId);
        
        if (kDebugMode) {
          debugPrint('Synced ${pendingSessions.length} sessions');
        }
      }
    } catch (e) {
      await MonitoringService.logError(e, null, context: 'sync_sessions');
    }
  }

  /// Force sync all data
  Future<void> forceSync() async {
    await _syncAllData();
  }

  /// Sync specific data type
  Future<void> syncData(SyncDataType dataType) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) return;

    switch (dataType) {
      case SyncDataType.projects:
        await _syncProjects(userId);
        break;
      case SyncDataType.tasks:
        await _syncTasks(userId);
        break;
      case SyncDataType.sessions:
        await _syncSessions(userId);
        break;
    }
  }

  /// Get sync status
  SyncStatus getSyncStatus() {
    return _syncStatusController.hasListener 
        ? _syncStatusController.stream.value 
        : SyncStatus.idle;
  }

  /// Dispose resources
  void dispose() {
    _stopPeriodicSync();
    _syncStatusController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}

enum SyncDataType {
  projects,
  tasks,
  sessions,
}
