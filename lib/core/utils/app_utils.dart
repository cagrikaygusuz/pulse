import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility functions for common operations
class AppUtils {
  AppUtils._();

  /// Format duration to MM:SS format
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration to HH:MM:SS format
  static String formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format duration to human readable format (e.g., "2 hours 30 minutes")
  static String formatDurationHuman(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else if (minutes > 0) {
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${minutes}m';
      }
    } else {
      return '${seconds}s';
    }
  }

  /// Format date to readable format
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  /// Format date and time to readable format
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, y, HH:mm').format(dateTime);
    }
  }

  /// Format date for heatmap (YYYY-MM-DD)
  static String formatDateForHeatmap(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse date from heatmap format (YYYY-MM-DD)
  static DateTime parseDateFromHeatmap(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  /// Calculate percentage
  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }

  /// Calculate streak from list of dates
  static int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Sort dates in descending order
    final sortedDates = List<DateTime>.from(dates)..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final date in sortedDates) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (dateOnly == currentDateOnly) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (dateOnly == currentDateOnly.subtract(const Duration(days: 1))) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Calculate completion rate
  static double calculateCompletionRate(int completed, int total) {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// Calculate average session length
  static Duration calculateAverageSessionLength(List<Duration> sessions) {
    if (sessions.isEmpty) return Duration.zero;
    
    final totalMinutes = sessions.fold<int>(0, (sum, duration) => sum + duration.inMinutes);
    return Duration(minutes: totalMinutes ~/ sessions.length);
  }

  /// Get peak hours from list of session times
  static List<int> getPeakHours(List<DateTime> sessionTimes) {
    final hourCounts = <int, int>{};
    
    for (final time in sessionTimes) {
      final hour = time.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedHours.take(3).map((e) => e.key).toList();
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters;
  }

  /// Validate task name
  static bool isValidTaskName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  /// Validate project name
  static bool isValidProjectName(String name) {
    return name.trim().isNotEmpty && name.length <= 50;
  }

  /// Validate duration
  static bool isValidDuration(Duration duration) {
    return duration.inMinutes >= 1 && duration.inMinutes <= 60;
  }

  /// Clamp duration to valid range
  static Duration clampDuration(Duration duration) {
    const minDuration = Duration(minutes: 1);
    const maxDuration = Duration(minutes: 60);
    
    if (duration < minDuration) return minDuration;
    if (duration > maxDuration) return maxDuration;
    return duration;
  }

  /// Convert Pomodoros to Duration
  static Duration pomodorosToDuration(int pomodoros) {
    return Duration(minutes: pomodoros * 25);
  }

  /// Convert Duration to Pomodoros
  static int durationToPomodoros(Duration duration) {
    return (duration.inMinutes / 25).round();
  }

  /// Get contrast color for background
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Calculate heatmap intensity level
  static int calculateHeatmapIntensity(int sessionCount) {
    if (sessionCount == 0) return 0;
    if (sessionCount <= 2) return 1;
    if (sessionCount <= 5) return 2;
    if (sessionCount <= 8) return 3;
    return 4;
  }

  /// Get heatmap color for intensity level
  static Color getHeatmapColor(int intensity) {
    const colors = [
      Color(0xFFF5F5F5), // No sessions
      Color(0xFFE3F2FD), // 1-2 sessions
      Color(0xFFBBDEFB), // 3-5 sessions
      Color(0xFF90CAF9), // 6-8 sessions
      Color(0xFFED6B06), // 9+ sessions
    ];
    
    return colors[intensity.clamp(0, colors.length - 1)];
  }

  /// Debounce function for search and input
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, callback);
  }

  /// Show snackbar with message
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error dialog
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    showSnackBar(context, 'Copied to clipboard');
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width >= 768;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width >= 1024;
  }

  /// Get responsive breakpoints
  static ResponsiveBreakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200) return ResponsiveBreakpoint.desktop;
    if (width >= 768) return ResponsiveBreakpoint.tablet;
    return ResponsiveBreakpoint.mobile;
  }
}

/// Responsive breakpoint enum
enum ResponsiveBreakpoint {
  mobile,
  tablet,
  desktop,
}
