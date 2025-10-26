import 'package:flutter/material.dart';

/// Application constants and configuration values
class AppConstants {
  AppConstants._();

  // Timer durations (in minutes)
  static const Duration defaultPomodoroDuration = Duration(minutes: 25);
  static const Duration shortBreakDuration = Duration(minutes: 5);
  static const Duration longBreakDuration = Duration(minutes: 15);
  
  // Timer durations (in minutes) - for backward compatibility
  static const int defaultPomodoroDurationMinutes = 25;
  static const int defaultShortBreakDurationMinutes = 5;
  static const int defaultLongBreakDurationMinutes = 15;
  
  // Pomodoro cycle configuration
  static const int pomodorosBeforeLongBreak = 4;
  static const int defaultPomodorosBeforeLongBreak = 4;
  
  // Timer limits
  static const Duration minTimerDuration = Duration(minutes: 1);
  static const Duration maxTimerDuration = Duration(minutes: 60);
  
  // Task and project limits
  static const int maxTaskNameLength = 100;
  static const int maxProjectNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Validation rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  
  // Database configuration
  static const String isarDatabaseName = 'pulse_database';
  static const int maxLocalSessions = 1000;
  static const int syncBatchSize = 50;
  
  // Firebase collections
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String tasksCollection = 'tasks';
  static const String pomodoroSessionsCollection = 'pomodoro_sessions';
  static const String achievementsCollection = 'achievements';
  static const String userSettingsCollection = 'user_settings';
  
  // Achievement thresholds
  static const int weekStreakThreshold = 7;
  static const int monthStreakThreshold = 30;
  static const int centuryClubThreshold = 100;
  static const int thousandHoursThreshold = 1000; // in minutes
  static const double focusedMindThreshold = 0.05; // 5% skip rate
  static const int unbreakableThreshold = 30; // days without skips
  
  // UI configuration
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double buttonElevation = 2.0;
  static const double appBarElevation = 0.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Timer tick interval
  static const Duration timerTickInterval = Duration(seconds: 1);
  
  // Notification channels
  static const String timerChannelId = 'timer_notifications';
  static const String breakChannelId = 'break_notifications';
  static const String achievementChannelId = 'achievement_notifications';
  
  // Notification IDs
  static const int timerCompletedNotificationId = 1;
  static const int breakStartedNotificationId = 2;
  static const int achievementUnlockedNotificationId = 3;
  
  // Sync configuration
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const int maxSyncRetries = 3;
  static const Duration syncTimeout = Duration(seconds: 30);
  
  // Heatmap configuration
  static const int heatmapIntensityLevels = 5;
  static const int heatmapDaysInYear = 365;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache configuration
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const int maxCacheSize = 100; // MB
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  static const String offlineErrorMessage = 'You are offline. Changes will be saved locally.';
  static const String syncErrorMessage = 'Sync error. Data will be synced when connection is restored.';
  
  // Success messages
  static const String sessionCompletedMessage = 'Session completed successfully!';
  static const String taskCreatedMessage = 'Task created successfully!';
  static const String projectCreatedMessage = 'Project created successfully!';
  static const String achievementUnlockedMessage = 'Achievement unlocked!';
  
  // App information
  static const String appName = 'Pulse';
  static const String appSlogan = 'Master your flow. Measure your focus.';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // URLs and links
  static const String privacyPolicyUrl = 'https://pulse-timer.com/privacy';
  static const String termsOfServiceUrl = 'https://pulse-timer.com/terms';
  static const String supportEmail = 'support@pulse-timer.com';
  static const String websiteUrl = 'https://pulse-timer.com';
  
  // Platform specific configurations
  static const Map<String, dynamic> platformConfig = {
    'android': {
      'minSdkVersion': 21,
      'targetSdkVersion': 34,
      'compileSdkVersion': 34,
    },
    'ios': {
      'minIosVersion': '12.0',
      'targetIosVersion': '17.0',
    },
    'windows': {
      'minWindowsVersion': '10.0.17763.0',
    },
    'macos': {
      'minMacosVersion': '10.14',
      'targetMacosVersion': '14.0',
    },
    'linux': {
      'minLinuxVersion': 'Ubuntu 18.04',
    },
  };
  
  // Development flags
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableCrashReporting = true;
  static const bool enableAnalytics = true;
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableSync = true;
  static const bool enableNotifications = true;
  static const bool enableAchievements = true;
  static const bool enableAnalytics = true;
  static const bool enableHeatmap = true;
  static const bool enableStatistics = true;
  static const bool enableDarkMode = true;
  static const bool enableLocalization = true;
  
  // Testing configuration
  static const bool enableTestMode = false;
  static const String testUserId = 'test_user_id';
  static const Duration testTimerDuration = Duration(seconds: 5);
  
  // Accessibility
  static const double minTouchTargetSize = 44.0; // logical pixels
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 2.0;
  
  // Performance thresholds
  static const Duration maxFrameTime = Duration(milliseconds: 16); // 60 FPS
  static const int maxMemoryUsage = 100; // MB
  static const Duration maxLoadTime = Duration(seconds: 3);
  
  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const bool requireStrongPasswords = true;
  static const bool enableBiometricAuth = true;
  
  // Backup and export
  static const String backupFileName = 'pulse_backup.json';
  static const String exportFileName = 'pulse_export.json';
  static const Duration backupInterval = Duration(hours: 24);
  static const int maxBackupFiles = 7;
}
