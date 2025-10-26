import 'package:isar/isar.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/pomodoro_session_model.dart';
import '../../core/constants/app_constants.dart';

/// Isar database service for local data storage
class IsarService {
  static IsarService? _instance;
  static Isar? _isar;

  IsarService._();

  /// Get singleton instance
  static IsarService get instance {
    _instance ??= IsarService._();
    return _instance!;
  }

  /// Get Isar instance
  static Future<Isar> get isar async {
    _isar ??= await _openIsar();
    return _isar!;
  }

  /// Open Isar database
  static Future<Isar> _openIsar() async {
    return await Isar.open(
      [
        ProjectModelSchema,
        TaskModelSchema,
        PomodoroSessionModelSchema,
      ],
      name: AppConstants.isarDatabaseName,
      directory: await Isar.getApplicationDocumentsDirectory(),
    );
  }

  /// Close Isar database
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Clear all data (for testing)
  static Future<void> clearAll() async {
    final isarInstance = await isar;
    await isarInstance.writeTxn(() async {
      await isarInstance.clear<ProjectModel>();
      await isarInstance.clear<TaskModel>();
      await isarInstance.clear<PomodoroSessionModel>();
    });
  }

  /// Get database size in bytes
  static Future<int> getDatabaseSize() async {
    final isarInstance = await isar;
    return await isarInstance.getSize();
  }

  /// Check if database is healthy
  static Future<bool> isHealthy() async {
    try {
      final isarInstance = await isar;
      // Try to read from each collection
      await isarInstance.projects.count();
      await isarInstance.tasks.count();
      await isarInstance.pomodoroSessions.count();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get collection counts for debugging
  static Future<Map<String, int>> getCollectionCounts() async {
    final isarInstance = await isar;
    return {
      'projects': await isarInstance.projects.count(),
      'tasks': await isarInstance.tasks.count(),
      'sessions': await isarInstance.pomodoroSessions.count(),
    };
  }

  /// Export all data to JSON (for backup)
  static Future<Map<String, dynamic>> exportAllData() async {
    final isarInstance = await isar;
    
    final projects = await isarInstance.projects.where().findAll();
    final tasks = await isarInstance.tasks.where().findAll();
    final sessions = await isarInstance.pomodoroSessions.where().findAll();
    
    return {
      'projects': projects.map((p) => p.toEntity()).toList(),
      'tasks': tasks.map((t) => t.toEntity()).toList(),
      'sessions': sessions.map((s) => s.toEntity()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from JSON (for restore)
  static Future<void> importData(Map<String, dynamic> data) async {
    final isarInstance = await isar;
    
    await isarInstance.writeTxn(() async {
      // Clear existing data
      await isarInstance.clear<ProjectModel>();
      await isarInstance.clear<TaskModel>();
      await isarInstance.clear<PomodoroSessionModel>();
      
      // Import projects
      if (data['projects'] != null) {
        final projects = (data['projects'] as List)
            .map((p) => ProjectModel.fromEntity(p))
            .toList();
        await isarInstance.projects.putAll(projects);
      }
      
      // Import tasks
      if (data['tasks'] != null) {
        final tasks = (data['tasks'] as List)
            .map((t) => TaskModel.fromEntity(t))
            .toList();
        await isarInstance.tasks.putAll(tasks);
      }
      
      // Import sessions
      if (data['sessions'] != null) {
        final sessions = (data['sessions'] as List)
            .map((s) => PomodoroSessionModel.fromEntity(s))
            .toList();
        await isarInstance.pomodoroSessions.putAll(sessions);
      }
    });
  }

  /// Get pending sync items
  static Future<Map<String, List<dynamic>>> getPendingSyncItems() async {
    final isarInstance = await isar;
    
    final pendingProjects = await isarInstance.projects
        .where()
        .needsSyncEqualTo(true)
        .findAll();
    
    final pendingTasks = await isarInstance.tasks
        .where()
        .needsSyncEqualTo(true)
        .findAll();
    
    final pendingSessions = await isarInstance.pomodoroSessions
        .where()
        .needsSyncEqualTo(true)
        .findAll();
    
    return {
      'projects': pendingProjects.map((p) => p.toEntity()).toList(),
      'tasks': pendingTasks.map((t) => t.toEntity()).toList(),
      'sessions': pendingSessions.map((s) => s.toEntity()).toList(),
    };
  }

  /// Mark items as synced
  static Future<void> markItemsAsSynced(List<String> itemIds, String type) async {
    final isarInstance = await isar;
    
    await isarInstance.writeTxn(() async {
      switch (type) {
        case 'projects':
          for (final id in itemIds) {
            final project = await isarInstance.projects
                .where()
                .projectIdEqualTo(id)
                .findFirst();
            if (project != null) {
              project.markSynced();
              await isarInstance.projects.put(project);
            }
          }
          break;
        case 'tasks':
          for (final id in itemIds) {
            final task = await isarInstance.tasks
                .where()
                .taskIdEqualTo(id)
                .findFirst();
            if (task != null) {
              task.markSynced();
              await isarInstance.tasks.put(task);
            }
          }
          break;
        case 'sessions':
          for (final id in itemIds) {
            final session = await isarInstance.pomodoroSessions
                .where()
                .sessionIdEqualTo(id)
                .findFirst();
            if (session != null) {
              session.markSynced();
              await isarInstance.pomodoroSessions.put(session);
            }
          }
          break;
      }
    });
  }
}
