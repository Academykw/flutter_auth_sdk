library auth_exception;

enum AuthErrorType {
  invalidCredentials,
  invalidEmail,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  shortPassword,
  tokenExpired,
  network,
  validation,
  unknown, wrongPassword, networkError, tooManyRequests,
}

enum AuthErrorSeverity {
  info,
  warning,
  error,
  critical,
}

abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final AuthErrorType errorType;
  final AuthErrorSeverity severity;
  final Map<String, dynamic>? metadata;
  final StackTrace? stackTrace;

  const AuthException(
    this.message, {
    this.code,
    this.originalError,
    required this.errorType,
    this.severity = AuthErrorSeverity.error,
    this.metadata,
    this.stackTrace,
  });

  bool get isRecoverable => severity != AuthErrorSeverity.critical;
  
  bool get isNetworkRelated => errorType == AuthErrorType.network;
  
  bool get isValidationError => errorType == AuthErrorType.validation;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'errorType': errorType.toString(),
      'severity': severity.toString(),
      'metadata': metadata,
    };
  }

  @override
  String toString() => 'AuthException(message: $message, code: $code, type: $errorType)';
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Invalid email or password',
          code: 'invalid-credentials',
          errorType: AuthErrorType.invalidCredentials,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Invalid email address',
          code: 'invalid-email',
          errorType: AuthErrorType.invalidEmail,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'User not found',
          code: 'user-not-found',
          errorType: AuthErrorType.userNotFound,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Email is already in use',
          code: 'email-already-in-use',
          errorType: AuthErrorType.emailAlreadyInUse,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Password is too weak',
          code: 'weak-password',
          errorType: AuthErrorType.weakPassword,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class ShortPasswordException extends AuthException {
  const ShortPasswordException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Password is too short',
          code: 'short-password',
          errorType: AuthErrorType.shortPassword,
          severity: AuthErrorSeverity.warning,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Auth token has expired',
          code: 'token-expired',
          errorType: AuthErrorType.tokenExpired,
          severity: AuthErrorSeverity.error,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class NetworkException extends AuthException {
  const NetworkException({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Network error occurred',
          code: 'network-error',
          errorType: AuthErrorType.network,
          severity: AuthErrorSeverity.error,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}

class AuthUnknownException extends AuthException {
  const AuthUnknownException(
    String message, {
    dynamic originalError,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'unknown',
          errorType: AuthErrorType.unknown,
          severity: AuthErrorSeverity.error,
          originalError: originalError,
          metadata: metadata,
          stackTrace: stackTrace,
        );
}
