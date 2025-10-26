import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import 'monitoring_service.dart';

class PrivacyService {
  static final PrivacyService _instance = PrivacyService._internal();
  factory PrivacyService() => _instance;
  PrivacyService._internal();

  static const String _consentKey = 'analytics_consent';
  static const String _dataRetentionKey = 'data_retention_days';
  static const String _privacyPolicyAcceptedKey = 'privacy_policy_accepted';

  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();
  final SessionRepositoryImpl _sessionRepository = SessionRepositoryImpl();

  /// Check if user has given consent for analytics
  Future<bool> hasAnalyticsConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_consentKey) ?? false;
    } catch (e) {
      debugPrint('Failed to check analytics consent: $e');
      return false;
    }
  }

  /// Set analytics consent
  Future<void> setAnalyticsConsent(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, consent);
      
      if (!consent) {
        await _clearAnalyticsData();
      }
      
      if (kDebugMode) {
        debugPrint('Analytics consent set: $consent');
      }
    } catch (e) {
      debugPrint('Failed to set analytics consent: $e');
    }
  }

  /// Check if privacy policy has been accepted
  Future<bool> hasPrivacyPolicyAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_privacyPolicyAcceptedKey) ?? false;
    } catch (e) {
      debugPrint('Failed to check privacy policy acceptance: $e');
      return false;
    }
  }

  /// Set privacy policy acceptance
  Future<void> setPrivacyPolicyAccepted(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_privacyPolicyAcceptedKey, accepted);
      
      if (kDebugMode) {
        debugPrint('Privacy policy acceptance set: $accepted');
      }
    } catch (e) {
      debugPrint('Failed to set privacy policy acceptance: $e');
    }
  }

  /// Get data retention period in days
  Future<int> getDataRetentionDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_dataRetentionKey) ?? 365; // Default 1 year
    } catch (e) {
      debugPrint('Failed to get data retention period: $e');
      return 365;
    }
  }

  /// Set data retention period
  Future<void> setDataRetentionDays(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dataRetentionKey, days);
      
      if (kDebugMode) {
        debugPrint('Data retention period set: $days days');
      }
    } catch (e) {
      debugPrint('Failed to set data retention period: $e');
    }
  }

  /// Request user consent
  Future<bool> requestConsent() async {
    try {
      // This would typically show a consent dialog
      // For now, we'll return true as a placeholder
      await setAnalyticsConsent(true);
      return true;
    } catch (e) {
      debugPrint('Failed to request consent: $e');
      return false;
    }
  }

  /// Clear all analytics data
  Future<void> _clearAnalyticsData() async {
    try {
      // Clear local analytics data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentKey);
      
      // Clear remote analytics data
      await MonitoringService.logEvent('analytics_data_cleared', {});
      
      if (kDebugMode) {
        debugPrint('Analytics data cleared');
      }
    } catch (e) {
      debugPrint('Failed to clear analytics data: $e');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get all user data
      final projects = await _taskRepository.getProjects(userId);
      final sessions = await _sessionRepository.getSessions(userId);
      
      // Create export data
      final exportData = {
        'user_id': userId,
        'export_date': DateTime.now().toIso8601String(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'privacy_settings': {
          'analytics_consent': await hasAnalyticsConsent(),
          'data_retention_days': await getDataRetentionDays(),
          'privacy_policy_accepted': await hasPrivacyPolicyAccepted(),
        },
      };

      if (kDebugMode) {
        debugPrint('User data exported successfully');
      }

      return exportData;
    } catch (e) {
      debugPrint('Failed to export user data: $e');
      rethrow;
    }
  }

  /// Delete all user data
  Future<void> deleteAllUserData() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Delete local data
      await _taskRepository.deleteAllUserData(userId);
      await _sessionRepository.deleteAllUserData(userId);
      
      // Delete remote data
      await _authRepository.deleteUser();
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (kDebugMode) {
        debugPrint('All user data deleted');
      }
    } catch (e) {
      debugPrint('Failed to delete user data: $e');
      rethrow;
    }
  }

  /// Anonymize user data
  Future<void> anonymizeUserData() async {
    try {
      final userId = _authRepository.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Anonymize local data
      await _taskRepository.anonymizeUserData(userId);
      await _sessionRepository.anonymizeUserData(userId);
      
      // Clear personal information
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentKey);
      await prefs.remove(_privacyPolicyAcceptedKey);
      
      if (kDebugMode) {
        debugPrint('User data anonymized');
      }
    } catch (e) {
      debugPrint('Failed to anonymize user data: $e');
      rethrow;
    }
  }

  /// Get privacy policy text
  String getPrivacyPolicyText() {
    return '''
# Privacy Policy

## Data Collection
We collect minimal data to provide our service:
- Session completion times (for analytics)
- Task names and durations (for your productivity insights)
- App usage statistics (to improve the app)

## Data We Do NOT Collect
- Personal information beyond your email
- Task content or descriptions
- Location data
- Device identifiers

## Data Usage
Your data is used to:
- Provide personalized productivity insights
- Improve app performance and features
- Generate analytics and reports

## Data Storage
- Data is stored securely using Firebase
- Local data is encrypted using Isar database
- Data is retained for the period you specify

## Your Rights
- Access your data
- Export your data
- Delete your data
- Anonymize your data
- Withdraw consent at any time

## Contact
For privacy concerns, contact us at privacy@pulse-timer.com
''';
  }

  /// Get terms of service text
  String getTermsOfServiceText() {
    return '''
# Terms of Service

## Acceptance
By using Pulse, you agree to these terms.

## Use License
- You may use Pulse for personal productivity
- You may not reverse engineer or redistribute the app
- You may not use the app for illegal purposes

## User Content
- You retain ownership of your data
- You grant us license to process your data for service provision
- You are responsible for your content

## Privacy
- Your privacy is important to us
- Please review our Privacy Policy
- We collect minimal data necessary for service provision

## Limitation of Liability
- We provide the service "as is"
- We are not liable for any damages
- Use at your own risk

## Changes
- We may update these terms
- Continued use constitutes acceptance
- We will notify you of significant changes

## Contact
For questions, contact us at support@pulse-timer.com
''';
  }
}
