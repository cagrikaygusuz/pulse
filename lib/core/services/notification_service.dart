import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permission
      await _requestPermission();

      // Initialize Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Initialize iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(initSettings);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('Notification service initialized');
      }
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  /// Request notification permission
  Future<bool> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Show timer completion notification
  Future<void> showTimerCompletionNotification({
    required String taskName,
    required Duration duration,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'timer_completion',
        'Timer Completion',
        channelDescription: 'Notifications for completed Pomodoro sessions',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        'Session Complete! 🎉',
        'Great job! You completed $taskName in ${duration.inMinutes} minutes.',
        details,
      );
    } catch (e) {
      debugPrint('Failed to show timer completion notification: $e');
    }
  }

  /// Show break reminder notification
  Future<void> showBreakReminderNotification({
    required String breakType,
    required Duration duration,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'break_reminder',
        'Break Reminder',
        channelDescription: 'Notifications for break reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        2,
        'Time for a $breakType! ☕',
        'Take a ${duration.inMinutes}-minute break to recharge.',
        details,
      );
    } catch (e) {
      debugPrint('Failed to show break reminder notification: $e');
    }
  }

  /// Show achievement notification
  Future<void> showAchievementNotification({
    required String achievementName,
    required String description,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'achievement',
        'Achievement Unlocked',
        channelDescription: 'Notifications for unlocked achievements',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        3,
        'Achievement Unlocked! 🏆',
        '$achievementName: $description',
        details,
      );
    } catch (e) {
      debugPrint('Failed to show achievement notification: $e');
    }
  }

  /// Show daily reminder notification
  Future<void> showDailyReminderNotification() async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Daily reminders to use the app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        4,
        'Ready to focus? 🎯',
        'Start your day with a productive Pomodoro session!',
        details,
      );
    } catch (e) {
      debugPrint('Failed to show daily reminder notification: $e');
    }
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Daily reminders to use the app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        5,
        'Ready to focus? 🎯',
        'Start your day with a productive Pomodoro session!',
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reminder: $e');
    }
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(5);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true;
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  /// Helper method to get next instance of time
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}
