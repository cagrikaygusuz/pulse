import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailUseCase(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      return User.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }
}

/// Use case for creating a new user account
class CreateUserWithEmailUseCase {
  final AuthRepository _authRepository;

  CreateUserWithEmailUseCase(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Account creation failed');
      }

      return User.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }
}

/// Use case for signing out
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
}

/// Use case for sending password reset email
class SendPasswordResetEmailUseCase {
  final AuthRepository _authRepository;

  SendPasswordResetEmailUseCase(this._authRepository);

  Future<void> call(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('Password reset email failed: ${e.toString()}');
    }
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final AuthRepository _authRepository;

  UpdateUserProfileUseCase(this._authRepository);

  Future<void> call({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _authRepository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
}

/// Use case for updating user email
class UpdateUserEmailUseCase {
  final AuthRepository _authRepository;

  UpdateUserEmailUseCase(this._authRepository);

  Future<void> call(String newEmail) async {
    try {
      await _authRepository.updateUserEmail(newEmail);
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
    }
  }
}

/// Use case for updating user password
class UpdateUserPasswordUseCase {
  final AuthRepository _authRepository;

  UpdateUserPasswordUseCase(this._authRepository);

  Future<void> call(String newPassword) async {
    try {
      await _authRepository.updateUserPassword(newPassword);
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }
}

/// Use case for deleting user account
class DeleteUserUseCase {
  final AuthRepository _authRepository;

  DeleteUserUseCase(this._authRepository);

  Future<void> call() async {
    try {
      await _authRepository.deleteUser();
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }
}
