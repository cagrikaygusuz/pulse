import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Firebase service for authentication and Firestore operations
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  FirebaseService._();

  /// Get singleton instance
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    
    // Configure Firestore settings
    _firestore!.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user stream
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user email
  static Future<void> updateUserEmail(String newEmail) async {
    try {
      await currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user password
  static Future<void> updateUserPassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete user account
  static Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get Firestore collection references
  static CollectionReference get usersCollection => 
      firestore.collection(AppConstants.usersCollection);
  
  static CollectionReference get projectsCollection => 
      firestore.collection(AppConstants.projectsCollection);
  
  static CollectionReference get tasksCollection => 
      firestore.collection(AppConstants.tasksCollection);
  
  static CollectionReference get pomodoroSessionsCollection => 
      firestore.collection(AppConstants.pomodoroSessionsCollection);
  
  static CollectionReference get achievementsCollection => 
      firestore.collection(AppConstants.achievementsCollection);
  
  static CollectionReference get userSettingsCollection => 
      firestore.collection(AppConstants.userSettingsCollection);

  /// Get user-specific collections
  static CollectionReference getUserProjects(String userId) => 
      projectsCollection.where('userId', isEqualTo: userId).snapshots().first as CollectionReference;
  
  static CollectionReference getUserTasks(String userId) => 
      tasksCollection.where('userId', isEqualTo: userId).snapshots().first as CollectionReference;
  
  static CollectionReference getUserSessions(String userId) => 
      pomodoroSessionsCollection.where('userId', isEqualTo: userId).snapshots().first as CollectionReference;

  /// Batch write operations
  static WriteBatch batch() => firestore.batch();

  /// Run transaction
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await firestore.runTransaction(updateFunction);
  }

  /// Handle Firebase Auth exceptions
  static Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-credential':
        return Exception('Invalid credentials');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'requires-recent-login':
        return Exception('Please sign in again to complete this action');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }

  /// Handle Firestore exceptions
  static Exception handleFirestoreException(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return Exception('Permission denied');
        case 'unavailable':
          return Exception('Service is temporarily unavailable');
        case 'deadline-exceeded':
          return Exception('Request timed out');
        case 'resource-exhausted':
          return Exception('Too many requests');
        case 'unauthenticated':
          return Exception('Please sign in to continue');
        case 'not-found':
          return Exception('Resource not found');
        default:
          return Exception('Firestore error: ${e.message}');
      }
    }
    return Exception('Unknown error: ${e.toString()}');
  }

  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      return ['unavailable', 'deadline-exceeded', 'resource-exhausted'].contains(error.code);
    }
    return false;
  }

  /// Get server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Get array union
  static FieldValue arrayUnion(List<dynamic> elements) => FieldValue.arrayUnion(elements);

  /// Get array remove
  static FieldValue arrayRemove(List<dynamic> elements) => FieldValue.arrayRemove(elements);

  /// Get increment
  static FieldValue increment(int value) => FieldValue.increment(value);

  /// Get delete field
  static FieldValue get deleteField => FieldValue.delete();
}
