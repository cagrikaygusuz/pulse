import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const String _encryptionKeyKey = 'encryption_key';
  static const String _saltKey = 'salt';

  /// Generate a random salt
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Generate encryption key from password
  String _generateKey(String password, String salt) {
    final key = utf8.encode(password + salt);
    final digest = sha256.convert(key);
    return base64Encode(digest.bytes);
  }

  /// Encrypt data
  Future<String> encrypt(String data, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get or generate salt
      String salt = prefs.getString(_saltKey) ?? '';
      if (salt.isEmpty) {
        salt = _generateSalt();
        await prefs.setString(_saltKey, salt);
      }
      
      // Generate key
      final key = _generateKey(password, salt);
      
      // Simple XOR encryption (for demonstration)
      // In production, use a proper encryption library
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(data);
      final encryptedBytes = <int>[];
      
      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64Encode(encryptedBytes);
    } catch (e) {
      debugPrint('Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt data
  Future<String> decrypt(String encryptedData, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get salt
      final salt = prefs.getString(_saltKey) ?? '';
      if (salt.isEmpty) {
        throw Exception('No salt found');
      }
      
      // Generate key
      final key = _generateKey(password, salt);
      
      // Decrypt
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64Decode(encryptedData);
      final decryptedBytes = <int>[];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption failed: $e');
      rethrow;
    }
  }

  /// Hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate password strength
  bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialChar;
  }

  /// Generate secure random string
  String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Generate UUID
  String generateUUID() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    
    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Sanitize input
  String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input.replaceAll('<', '').replaceAll('>', '').replaceAll('"', '').replaceAll("'", '');
  }

  /// Validate input length
  bool isValidInputLength(String input, int minLength, int maxLength) {
    return input.length >= minLength && input.length <= maxLength;
  }

  /// Check for malicious content
  bool containsMaliciousContent(String input) {
    final maliciousPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'on\w+\s*=',
      r'<iframe[^>]*>.*?</iframe>',
      r'<object[^>]*>.*?</object>',
      r'<embed[^>]*>.*?</embed>',
    ];
    
    for (final pattern in maliciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }
    
    return false;
  }

  /// Generate API key
  String generateApiKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate API key format
  bool isValidApiKey(String apiKey) {
    return RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(apiKey);
  }

  /// Generate session token
  String generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate session token format
  bool isValidSessionToken(String token) {
    return RegExp(r'^[A-Za-z0-9]{64}$').hasMatch(token);
  }

  /// Generate CSRF token
  String generateCSRFToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate CSRF token format
  bool isValidCSRFToken(String token) {
    return RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(token);
  }

  /// Generate nonce
  String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate nonce format
  bool isValidNonce(String nonce) {
    return RegExp(r'^[A-Za-z0-9]{16}$').hasMatch(nonce);
  }

  /// Generate challenge
  String generateChallenge() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate challenge format
  bool isValidChallenge(String challenge) {
    return RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(challenge);
  }

  /// Generate verification code
  String generateVerificationCode() {
    final random = Random.secure();
    return (random.nextInt(900000) + 100000).toString(); // 6-digit code
  }

  /// Validate verification code format
  bool isValidVerificationCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// Generate recovery code
  String generateRecoveryCode() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate recovery code format
  bool isValidRecoveryCode(String code) {
    return RegExp(r'^[A-Za-z0-9]{16}$').hasMatch(code);
  }

  /// Generate backup code
  String generateBackupCode() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[+/=]'), '');
  }

  /// Validate backup code format
  bool isValidBackupCode(String code) {
    return RegExp(r'^[A-Za-z0-9]{24}$').hasMatch(code);
  }
}
