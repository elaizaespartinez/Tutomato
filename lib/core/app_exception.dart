/// An error with a message that is safe to show to the user as-is.
/// Services and repositories throw this instead of raw Firebase errors.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
