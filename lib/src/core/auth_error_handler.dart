library auth_error_handler;

import 'auth_exception.dart';

typedef ErrorCallback = void Function(AuthException error);
typedef ErrorTransformer = AuthException Function(AuthException error);
typedef ErrorLogger = void Function(AuthException error, StackTrace? stackTrace);

class AuthErrorHandler {
  final ErrorCallback? onError;
  final ErrorTransformer? errorTransformer;
  final ErrorLogger? logger;
  final Map<AuthErrorType, ErrorCallback>? errorTypeHandlers;
  final bool shouldRethrow;

  const AuthErrorHandler({
    this.onError,
    this.errorTransformer,
    this.logger,
    this.errorTypeHandlers,
    this.shouldRethrow = true,
  });

  void handleError(AuthException error) {
    // Log the error if logger is provided
    logger?.call(error, error.stackTrace);

    // Transform error if transformer is provided
    final transformedError = errorTransformer?.call(error) ?? error;

    // Call specific error type handler if available
    final typeHandler = errorTypeHandlers?[error.errorType];
    if (typeHandler != null) {
      typeHandler(transformedError);
      return;
    }

    // Call general error handler
    onError?.call(transformedError);
  }

  factory AuthErrorHandler.withDefaults({
    ErrorCallback? onError,
    ErrorLogger? logger,
  }) {
    return AuthErrorHandler(
      onError: onError,
      logger: logger ?? (error, stackTrace) {
        print('Auth Error: ${error.message}');
        if (stackTrace != null) {
          print('Stack trace: $stackTrace');
        }
      },
      shouldRethrow: true,
    );
  }

  factory AuthErrorHandler.silent({
    ErrorCallback? onError,
    ErrorLogger? logger,
  }) {
    return AuthErrorHandler(
      onError: onError,
      logger: logger,
      shouldRethrow: false,
    );
  }
}

class AuthResult<T> {
  final T? data;
  final AuthException? error;

  const AuthResult.success(this.data) : error = null;
  const AuthResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  R when<R>({
    required R Function(T data) success,
    required R Function(AuthException error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error!);
    }
  }

  AuthResult<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      return AuthResult.success(transform(data as T));
    } else {
      return AuthResult.failure(error);
    }
  }
}
