import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'monitoring_service.dart';

class ErrorHandler {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize error handling
  static Future<void> initialize() async {
    // Set up global error handlers
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics.recordFlutterFatalError(details);
    };

    // Set up platform error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Handle and log errors
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Error: $error');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }

      // Log to crashlytics
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
        information: additionalData?.entries
            .map((e) => DiagnosticsProperty(e.key, e.value))
            .toList(),
      );

      // Log custom event
      await MonitoringService.logCustomError(
        'Error: ${error.toString()}',
        stackTrace,
      );
    } catch (e) {
      debugPrint('Failed to handle error: $e');
    }
  }

  /// Handle Firebase Auth errors
  static String handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later';
        case 'email-already-in-use':
          return 'Email already in use';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-credential':
          return 'Invalid credentials';
        case 'operation-not-allowed':
          return 'Operation not allowed';
        case 'requires-recent-login':
          return 'Please sign in again to complete this action';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  /// Handle Firestore errors
  static String handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action';
        case 'unavailable':
          return 'Service is temporarily unavailable. Please try again later';
        case 'deadline-exceeded':
          return 'Request timed out. Please check your connection';
        case 'resource-exhausted':
          return 'Too many requests. Please try again later';
        case 'unauthenticated':
          return 'Please sign in to continue';
        case 'not-found':
          return 'The requested resource was not found';
        default:
          return 'Database error: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  /// Handle network errors
  static String handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Changes will be saved locally';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again';
    } else if (error is HttpException) {
      return 'Network error: ${error.message}';
    }
    return 'Network error occurred';
  }

  /// Handle validation errors
  static String handleValidationError(dynamic error) {
    if (error is FormatException) {
      return 'Invalid format: ${error.message}';
    } else if (error is ArgumentError) {
      return 'Invalid argument: ${error.message}';
    }
    return 'Validation error occurred';
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is SocketException || error is TimeoutException) {
      return handleNetworkError(error);
    } else if (error is FormatException || error is ArgumentError) {
      return handleValidationError(error);
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Check if error should be retried
  static bool shouldRetry(dynamic error) {
    if (error is FirebaseException) {
      return ['unavailable', 'deadline-exceeded', 'resource-exhausted']
          .contains(error.code);
    }
    return error is SocketException || error is TimeoutException;
  }

  /// Retry operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration baseDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries || !shouldRetry(e)) {
          await handleError(e, null, context: 'retry_operation');
          rethrow;
        }
        
        // Exponential backoff
        final delay = baseDelay * (1 << (attempts - 1));
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
