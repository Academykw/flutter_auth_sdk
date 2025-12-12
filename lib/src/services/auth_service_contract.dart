import '../core/auth_config.dart';
import '../core/auth_state.dart';
import '../core/auth_error_handler.dart';

abstract class AuthService {
  Stream<AuthState> get authStateChanges;

  AuthState get currentUser;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  });

  Future<void> signInWithGoogle({
    AuthErrorHandler? errorHandler,
  });

  Future<void> signInWithApple({
    AuthErrorHandler? errorHandler,
  });

  Future<void> signOut({
    AuthErrorHandler? errorHandler,
  });

  Future<void> initialize(AuthConfig config);

  Future<AuthResult<void>> signInWithEmailAndPasswordResult({
    required String email,
    required String password,
  });

  Future<AuthResult<void>> signUpWithEmailAndPasswordResult({
    required String email,
    required String password,
  });

  Future<AuthResult<void>> signInWithGoogleResult();

  Future<AuthResult<void>> signInWithAppleResult();
}
