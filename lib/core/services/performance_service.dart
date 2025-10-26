import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PerformanceService {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];

  /// Start a performance timer
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// End a performance timer
  static void endTimer(String name) {
    final timer = _timers.remove(name);
    if (timer != null) {
      timer.stop();
      final metric = PerformanceMetric(
        name: name,
        duration: timer.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
      _metrics.add(metric);
      
      if (kDebugMode) {
        debugPrint('Performance: $name took ${timer.elapsedMilliseconds}ms');
      }
    }
  }

  /// Get performance metrics
  static List<PerformanceMetric> getMetrics() {
    return List.unmodifiable(_metrics);
  }

  /// Clear performance metrics
  static void clearMetrics() {
    _metrics.clear();
  }

  /// Get average performance for a metric
  static double getAveragePerformance(String name) {
    final metrics = _metrics.where((m) => m.name == name).toList();
    if (metrics.isEmpty) return 0.0;
    
    final total = metrics.fold<int>(0, (sum, metric) => sum + metric.duration);
    return total / metrics.length;
  }

  /// Track memory usage
  static void trackMemoryUsage() {
    if (kDebugMode) {
      final info = ProcessInfo.currentRss;
      debugPrint('Memory usage: ${info ~/ 1024 ~/ 1024} MB');
    }
  }

  /// Track frame rate
  static void trackFrameRate() {
    if (kDebugMode) {
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        debugPrint('Frame rendered at: ${timeStamp.inMilliseconds}');
      });
    }
  }

  /// Track widget build time
  static T trackWidgetBuild<T>(String widgetName, T Function() builder) {
    startTimer('widget_build_$widgetName');
    final result = builder();
    endTimer('widget_build_$widgetName');
    return result;
  }

  /// Track async operation
  static Future<T> trackAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer('async_$operationName');
    try {
      final result = await operation();
      endTimer('async_$operationName');
      return result;
    } catch (e) {
      endTimer('async_$operationName');
      rethrow;
    }
  }

  /// Track database operation
  static Future<T> trackDatabaseOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer('db_$operationName');
    try {
      final result = await operation();
      endTimer('db_$operationName');
      return result;
    } catch (e) {
      endTimer('db_$operationName');
      rethrow;
    }
  }

  /// Track network operation
  static Future<T> trackNetworkOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer('network_$operationName');
    try {
      final result = await operation();
      endTimer('network_$operationName');
      return result;
    } catch (e) {
      endTimer('network_$operationName');
      rethrow;
    }
  }
}

class PerformanceMetric {
  final String name;
  final int duration; // in milliseconds
  final DateTime timestamp;

  const PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, duration: ${duration}ms, timestamp: $timestamp)';
  }
}
