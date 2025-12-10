import '../core/auth_config.dart';
import '../core/auth_state.dart';

abstract class AuthService {

  Stream<AuthState> get authStateChanges;


  AuthState get currentUser;


  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });


  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });


  Future<void> signInWithGoogle();

  Future<void> signInWithApple();


  Future<void> signOut();
  

  Future<void> initialize(AuthConfig config);
}
