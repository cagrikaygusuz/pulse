import 'package:firebase_auth/firebase_auth.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Get current user
  User? get currentUser;

  /// Get current user ID
  String? get currentUserId;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Get authentication state stream
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Update user email
  Future<void> updateUserEmail(String newEmail);

  /// Update user password
  Future<void> updateUserPassword(String newPassword);

  /// Delete user account
  Future<void> deleteUser();
}
