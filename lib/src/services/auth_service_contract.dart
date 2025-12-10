import '../core/auth_config.dart';
import '../core/auth_state.dart';

/// Contract for Authentication Service
abstract class AuthService {
  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges;

  /// Current auth state
  AuthState get currentUser;

  /// Sign in with Email and Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with Email and Password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<void> signInWithGoogle();

  /// Sign in with Apple
  Future<void> signInWithApple();

  /// Sign out
  Future<void> signOut();
  
  /// Initialize with configuration
  Future<void> initialize(AuthConfig config);
}
