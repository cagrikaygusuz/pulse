import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class MonitoringService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize monitoring services
  static Future<void> initialize() async {
    if (kDebugMode) {
      // Disable crashlytics in debug mode
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
    } else {
      // Enable crashlytics in release mode
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }
  }

  /// Log a custom event
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Failed to log event: $e');
    }
  }

  /// Log user property
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }

  /// Log user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Failed to log screen view: $e');
    }
  }

  /// Log timer start
  static Future<void> logTimerStart(String taskId, Duration duration) async {
    await logEvent('timer_start', {
      'task_id': taskId,
      'duration_minutes': duration.inMinutes,
    });
  }

  /// Log timer completion
  static Future<void> logTimerComplete(String taskId, Duration duration) async {
    await logEvent('timer_complete', {
      'task_id': taskId,
      'duration_minutes': duration.inMinutes,
    });
  }

  /// Log timer skip
  static Future<void> logTimerSkip(String taskId, String reason) async {
    await logEvent('timer_skip', {
      'task_id': taskId,
      'reason': reason,
    });
  }

  /// Log task creation
  static Future<void> logTaskCreate(String projectId) async {
    await logEvent('task_create', {
      'project_id': projectId,
    });
  }

  /// Log project creation
  static Future<void> logProjectCreate() async {
    await logEvent('project_create', {});
  }

  /// Log error
  static Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    try {
      await _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  /// Log custom error
  static Future<void> logCustomError(String message, StackTrace? stackTrace) async {
    try {
      await _crashlytics.recordError(
        Exception(message),
        stackTrace,
        fatal: false,
      );
    } catch (e) {
      debugPrint('Failed to log custom error: $e');
    }
  }

  /// Set custom key for crashlytics
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Failed to set custom key: $e');
    }
  }

  /// Log breadcrumb
  static Future<void> logBreadcrumb(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('Failed to log breadcrumb: $e');
    }
  }
}
