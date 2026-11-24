import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutomato/core/app_exception.dart';

/// Thin wrapper around Firebase Auth that turns Firebase's error codes into
/// messages a student can understand.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// "Forgot password?" sends a reset link to the email.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  /// Profile > Password & security.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AppException('Please log in again.');
    }
    try {
      // Firebase requires a recent login before changing a password.
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: currentPassword),
      );
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  AppException _friendly(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'That email address doesn\'t look right.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Email or password is incorrect.',
      'email-already-in-use' =>
        'An account with this email already exists. Try logging in.',
      'weak-password' =>
        'Use at least 8 characters, a letter, and a number.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Check your signal and try again.',
      'requires-recent-login' =>
        'Please log out and log in again, then retry.',
      _ => 'Something went wrong. Please try again.',
    };
    return AppException(message, code: e.code);
  }
}
