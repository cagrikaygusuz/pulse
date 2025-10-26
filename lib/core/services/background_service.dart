import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'monitoring_service.dart';

class BackgroundService {
  static const String _taskName = 'pomodoro_timer_task';
  static const String _isolateName = 'pomodoro_timer_isolate';

  /// Initialize background service
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      
      if (kDebugMode) {
        debugPrint('Background service initialized');
      }
    } catch (e) {
      debugPrint('Failed to initialize background service: $e');
    }
  }

  /// Start background timer
  static Future<void> startBackgroundTimer({
    required String taskId,
    required String taskName,
    required Duration duration,
  }) async {
    try {
      await Workmanager().registerOneOffTask(
        _taskName,
        _taskName,
        inputData: {
          'taskId': taskId,
          'taskName': taskName,
          'durationMinutes': duration.inMinutes,
          'startTime': DateTime.now().millisecondsSinceEpoch,
        },
        initialDelay: duration,
      );
      
      if (kDebugMode) {
        debugPrint('Background timer started for $taskName');
      }
    } catch (e) {
      debugPrint('Failed to start background timer: $e');
    }
  }

  /// Cancel background timer
  static Future<void> cancelBackgroundTimer() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
      
      if (kDebugMode) {
        debugPrint('Background timer cancelled');
      }
    } catch (e) {
      debugPrint('Failed to cancel background timer: $e');
    }
  }

  /// Start periodic sync
  static Future<void> startPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        'sync_task',
        'sync_task',
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 5),
      );
      
      if (kDebugMode) {
        debugPrint('Periodic sync started');
      }
    } catch (e) {
      debugPrint('Failed to start periodic sync: $e');
    }
  }

  /// Stop periodic sync
  static Future<void> stopPeriodicSync() async {
    try {
      await Workmanager().cancelByUniqueName('sync_task');
      
      if (kDebugMode) {
        debugPrint('Periodic sync stopped');
      }
    } catch (e) {
      debugPrint('Failed to stop periodic sync: $e');
    }
  }

  /// Start daily reminder
  static Future<void> startDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      final delay = scheduledTime.difference(now);
      
      if (delay.isNegative) {
        // Schedule for next day
        final nextDay = scheduledTime.add(const Duration(days: 1));
        final nextDelay = nextDay.difference(now);
        
        await Workmanager().registerOneOffTask(
          'daily_reminder',
          'daily_reminder',
          initialDelay: nextDelay,
        );
      } else {
        await Workmanager().registerOneOffTask(
          'daily_reminder',
          'daily_reminder',
          initialDelay: delay,
        );
      }
      
      if (kDebugMode) {
        debugPrint('Daily reminder scheduled for $hour:$minute');
      }
    } catch (e) {
      debugPrint('Failed to start daily reminder: $e');
    }
  }

  /// Stop daily reminder
  static Future<void> stopDailyReminder() async {
    try {
      await Workmanager().cancelByUniqueName('daily_reminder');
      
      if (kDebugMode) {
        debugPrint('Daily reminder stopped');
      }
    } catch (e) {
      debugPrint('Failed to stop daily reminder: $e');
    }
  }

  /// Get all registered tasks
  static Future<List<String>> getRegisteredTasks() async {
    try {
      return await Workmanager().getRegisteredTasks();
    } catch (e) {
      debugPrint('Failed to get registered tasks: $e');
      return [];
    }
  }

  /// Cancel all tasks
  static Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      
      if (kDebugMode) {
        debugPrint('All background tasks cancelled');
      }
    } catch (e) {
      debugPrint('Failed to cancel all tasks: $e');
    }
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'pomodoro_timer_task':
          await _handleTimerCompletion(inputData);
          break;
        case 'sync_task':
          await _handlePeriodicSync();
          break;
        case 'daily_reminder':
          await _handleDailyReminder();
          break;
        default:
          debugPrint('Unknown background task: $task');
      }
      
      return Future.value(true);
    } catch (e) {
      debugPrint('Background task failed: $e');
      return Future.value(false);
    }
  });
}

/// Handle timer completion
Future<void> _handleTimerCompletion(Map<String, dynamic> inputData) async {
  try {
    final taskId = inputData['taskId'] as String;
    final taskName = inputData['taskName'] as String;
    final durationMinutes = inputData['durationMinutes'] as int;
    
    // Show notification
    await NotificationService().showTimerCompletionNotification(
      taskName: taskName,
      duration: Duration(minutes: durationMinutes),
    );
    
    // Log event
    await MonitoringService.logEvent('timer_completed_background', {
      'task_id': taskId,
      'task_name': taskName,
      'duration_minutes': durationMinutes,
    });
    
    debugPrint('Timer completed in background: $taskName');
  } catch (e) {
    debugPrint('Failed to handle timer completion: $e');
  }
}

/// Handle periodic sync
Future<void> _handlePeriodicSync() async {
  try {
    // This would typically sync data with remote server
    debugPrint('Periodic sync executed in background');
    
    // Log event
    await MonitoringService.logEvent('periodic_sync_executed', {});
  } catch (e) {
    debugPrint('Failed to handle periodic sync: $e');
  }
}

/// Handle daily reminder
Future<void> _handleDailyReminder() async {
  try {
    // Show notification
    await NotificationService().showDailyReminderNotification();
    
    // Log event
    await MonitoringService.logEvent('daily_reminder_shown', {});
    
    debugPrint('Daily reminder shown in background');
  } catch (e) {
    debugPrint('Failed to handle daily reminder: $e');
  }
}
