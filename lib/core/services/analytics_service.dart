import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'monitoring_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isInitialized = false;

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set analytics collection enabled based on debug mode
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('Analytics service initialized');
      }
    } catch (e) {
      debugPrint('Failed to initialize analytics service: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      
      if (kDebugMode) {
        debugPrint('User ID set: $userId');
      }
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      
      if (kDebugMode) {
        debugPrint('User property set: $name = $value');
      }
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      
      if (kDebugMode) {
        debugPrint('Screen view logged: $screenName');
      }
    } catch (e) {
      debugPrint('Failed to log screen view: $e');
    }
  }

  /// Log timer start
  Future<void> logTimerStart({
    required String taskId,
    required String taskName,
    required Duration duration,
    required String sessionType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'timer_start',
        parameters: {
          'task_id': taskId,
          'task_name': taskName,
          'duration_minutes': duration.inMinutes,
          'session_type': sessionType,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Timer start logged: $taskName');
      }
    } catch (e) {
      debugPrint('Failed to log timer start: $e');
    }
  }

  /// Log timer completion
  Future<void> logTimerComplete({
    required String taskId,
    required String taskName,
    required Duration duration,
    required String sessionType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'timer_complete',
        parameters: {
          'task_id': taskId,
          'task_name': taskName,
          'duration_minutes': duration.inMinutes,
          'session_type': sessionType,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Timer completion logged: $taskName');
      }
    } catch (e) {
      debugPrint('Failed to log timer completion: $e');
    }
  }

  /// Log timer skip
  Future<void> logTimerSkip({
    required String taskId,
    required String taskName,
    required String reason,
    required Duration completedDuration,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'timer_skip',
        parameters: {
          'task_id': taskId,
          'task_name': taskName,
          'reason': reason,
          'completed_duration_minutes': completedDuration.inMinutes,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Timer skip logged: $taskName');
      }
    } catch (e) {
      debugPrint('Failed to log timer skip: $e');
    }
  }

  /// Log task creation
  Future<void> logTaskCreate({
    required String taskId,
    required String taskName,
    required String projectId,
    required Duration estimatedDuration,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_create',
        parameters: {
          'task_id': taskId,
          'task_name': taskName,
          'project_id': projectId,
          'estimated_duration_minutes': estimatedDuration.inMinutes,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Task creation logged: $taskName');
      }
    } catch (e) {
      debugPrint('Failed to log task creation: $e');
    }
  }

  /// Log task completion
  Future<void> logTaskComplete({
    required String taskId,
    required String taskName,
    required Duration actualDuration,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_complete',
        parameters: {
          'task_id': taskId,
          'task_name': taskName,
          'actual_duration_minutes': actualDuration.inMinutes,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Task completion logged: $taskName');
      }
    } catch (e) {
      debugPrint('Failed to log task completion: $e');
    }
  }

  /// Log project creation
  Future<void> logProjectCreate({
    required String projectId,
    required String projectName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'project_create',
        parameters: {
          'project_id': projectId,
          'project_name': projectName,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Project creation logged: $projectName');
      }
    } catch (e) {
      debugPrint('Failed to log project creation: $e');
    }
  }

  /// Log achievement unlock
  Future<void> logAchievementUnlock({
    required String achievementId,
    required String achievementName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'achievement_unlock',
        parameters: {
          'achievement_id': achievementId,
          'achievement_name': achievementName,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Achievement unlock logged: $achievementName');
      }
    } catch (e) {
      debugPrint('Failed to log achievement unlock: $e');
    }
  }

  /// Log app usage
  Future<void> logAppUsage({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_usage',
        parameters: {
          'action': action,
          ...?parameters,
        },
      );
      
      if (kDebugMode) {
        debugPrint('App usage logged: $action');
      }
    } catch (e) {
      debugPrint('Failed to log app usage: $e');
    }
  }

  /// Log error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? context,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'error_occurred',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (context != null) 'context': context,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Error logged: $errorType - $errorMessage');
      }
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  /// Log user engagement
  Future<void> logUserEngagement({
    required String engagementType,
    required int value,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: {
          'engagement_type': engagementType,
          'value': value,
        },
      );
      
      if (kDebugMode) {
        debugPrint('User engagement logged: $engagementType = $value');
      }
    } catch (e) {
      debugPrint('Failed to log user engagement: $e');
    }
  }

  /// Log feature usage
  Future<void> logFeatureUsage({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'feature_name': featureName,
          ...?parameters,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Feature usage logged: $featureName');
      }
    } catch (e) {
      debugPrint('Failed to log feature usage: $e');
    }
  }

  /// Get analytics instance
  FirebaseAnalytics get analytics => _analytics;
}
