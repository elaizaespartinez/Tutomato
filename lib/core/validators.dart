import 'package:tutomato/core/constants.dart';

/// Form validators. Each returns an error message, or null when valid, so they
/// can be passed straight to a TextFormField's `validator:`.
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your name.';
    if (v.length > 40) return 'Keep your name under 40 characters.';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email address.';
    if (!_emailPattern.hasMatch(v)) return 'That email address doesn\'t look right.';
    return null;
  }

  /// Matches the hint on the Sign up screen:
  /// "Use at least 8 characters, a letter, and a number."
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please create a password.';
    if (v.length < AppConstants.minPasswordLength ||
        !_hasLetter.hasMatch(v) ||
        !_hasDigit.hasMatch(v)) {
      return 'Use at least ${AppConstants.minPasswordLength} characters, '
          'a letter, and a number.';
    }
    return null;
  }

  static String? confirmPassword(String? password, String? confirm) {
    if ((confirm ?? '').isEmpty) return 'Please re-enter your password.';
    if (password != confirm) return 'Passwords don\'t match.';
    return null;
  }

  /// Log in only needs "not empty"; the server decides if it is right.
  static String? existingPassword(String? value) =>
      (value ?? '').isEmpty ? 'Please enter your password.' : null;

  static String? taskTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Give your task a name.';
    if (v.length > 80) return 'Keep the task name under 80 characters.';
    return null;
  }
}
