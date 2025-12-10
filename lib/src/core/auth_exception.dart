/// Custom exception utility for Auth SDK
library auth_exception;

/// Base class for all Auth SDK specific exceptions
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

/// Thrown when email/password combination is incorrect
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({String? message}) 
      : super(message ?? 'Invalid email or password', code: 'invalid-credentials');
}

/// Thrown when the user account is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException({String? message}) 
      : super(message ?? 'User not found', code: 'user-not-found');
}

/// Thrown when sign up fails because email is already used
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException({String? message}) 
      : super(message ?? 'Email is already in use', code: 'email-already-in-use');
}

/// Thrown when the password is too weak
class WeakPasswordException extends AuthException {
  const WeakPasswordException({String? message}) 
      : super(message ?? 'Password is too weak', code: 'weak-password');
}

/// Thrown when the auth token has expired
class TokenExpiredException extends AuthException {
  const TokenExpiredException({String? message}) 
      : super(message ?? 'Auth token has expired', code: 'token-expired');
}

/// Thrown when there is a network issue
class NetworkException extends AuthException {
  const NetworkException({String? message}) 
      : super(message ?? 'Network error occurred', code: 'network-error');
}

/// Thrown for any other unknown errors
class AuthUnknownException extends AuthException {
  const AuthUnknownException(String message, {dynamic originalError}) 
      : super(message, code: 'unknown', originalError: originalError);
}
