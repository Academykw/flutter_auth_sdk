import 'dart:async';
import '../core/auth_config.dart';
import '../core/auth_exception.dart';
import '../core/auth_state.dart';
import '../core/auth_validator.dart';
import '../core/auth_error_handler.dart';
import 'auth_service_contract.dart';

class MockAuthService implements AuthService {
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();
  
  AuthState _currentUser = AuthState.unauthenticated();

  final Map<String, String> _mockUsers = {
    'test@example.com': 'password',
  };

  MockAuthService() {
    _authStateController.add(_currentUser);
  }

  @override
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  @override
  AuthState get currentUser => _currentUser;

  @override
  Future<void> initialize(AuthConfig config) async {
    // Mock init
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      AuthValidator.validateEmail(email);

      if (_mockUsers.containsKey(email)) {
        if (_mockUsers[email] == password) {
          _updateState(AuthState.authenticated({'email': email, 'uid': 'mock-uid-123'}));
          return;
        } else {
          throw InvalidCredentialsException(
            message: 'Wrong password provided for that user.',
            stackTrace: StackTrace.current,
          );
        }
      } else {
        throw UserNotFoundException(
          message: 'No user found for that email.',
          stackTrace: StackTrace.current,
        );
      }
    } on AuthException catch (e) {
      if (errorHandler != null) {
        errorHandler.handleError(e);
        if (errorHandler.shouldRethrow) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      AuthValidator.validateEmail(email);

      if (_mockUsers.containsKey(email)) {
        throw EmailAlreadyInUseException(
          stackTrace: StackTrace.current,
        );
      }
      
      AuthValidator.validatePassword(password);

      _mockUsers[email] = password;
      _updateState(AuthState.authenticated({'email': email, 'uid': 'mock-uid-new-${DateTime.now().millisecondsSinceEpoch}'}));
    } on AuthException catch (e) {
      if (errorHandler != null) {
        errorHandler.handleError(e);
        if (errorHandler.shouldRethrow) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signInWithGoogle({
    AuthErrorHandler? errorHandler,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _updateState(AuthState.authenticated({'email': 'google-user@example.com', 'displayName': 'Google User', 'uid': 'mock-google-uid'}));
  }

  @override
  Future<void> signInWithApple({
    AuthErrorHandler? errorHandler,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _updateState(AuthState.authenticated({'email': 'apple-user@example.com', 'displayName': 'Apple User', 'uid': 'mock-apple-uid'}));
  }

  @override
  Future<void> signOut({
    AuthErrorHandler? errorHandler,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _updateState(AuthState.unauthenticated());
  }

  @override
  Future<AuthResult<void>> signInWithEmailAndPasswordResult({
    required String email,
    required String password,
  }) async {
    try {
      await signInWithEmailAndPassword(email: email, password: password);
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  @override
  Future<AuthResult<void>> signUpWithEmailAndPasswordResult({
    required String email,
    required String password,
  }) async {
    try {
      await signUpWithEmailAndPassword(email: email, password: password);
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  @override
  Future<AuthResult<void>> signInWithGoogleResult() async {
    try {
      await signInWithGoogle();
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  @override
  Future<AuthResult<void>> signInWithAppleResult() async {
    try {
      await signInWithApple();
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  void _updateState(AuthState newState) {
    _currentUser = newState;
    _authStateController.add(newState);
  }
}
