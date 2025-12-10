import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/auth_config.dart';
import '../core/auth_exception.dart' as app_exception;
import '../core/auth_state.dart';
import 'auth_service_contract.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthState> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUserToAuthState);
  }

  @override
  AuthState get currentUser {
    return _mapFirebaseUserToAuthState(_firebaseAuth.currentUser);
  }

  AuthState _mapFirebaseUserToAuthState(User? user) {
    if (user != null) {
      // Check for token expiration could be done by forcing a token refresh, 
      // but standard stream usually handles it.
      return AuthState.authenticated(user);
    }
    return AuthState.unauthenticated();
  }

  @override
  Future<void> initialize(AuthConfig config) async {
    // Config not currently used in service layer, but available for future validation
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signInWithApple() async {
    // TODO: Implement Apple Sign In when package is fully integrated and tested
    throw UnimplementedError('Apple Sign In not yet implemented in this version.');
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        // Only sign out of google if we are signed in or just always try
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Exception _mapFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return app_exception.UserNotFoundException(message: error.message);
        case 'wrong-password':
          return app_exception.InvalidCredentialsException(message: error.message);
        case 'invalid-email':
          return app_exception.InvalidCredentialsException(message: 'Invalid email address.');
        case 'email-already-in-use':
          return const app_exception.EmailAlreadyInUseException(message: 'The account already exists for that email.');
        case 'weak-password':
          return app_exception.WeakPasswordException(message: error.message);
        case 'network-request-failed':
          return app_exception.NetworkException(message: error.message);
        default:
          return app_exception.AuthUnknownException(error.message ?? 'Unknown error', originalError: error);
      }
    }
    return app_exception.AuthUnknownException('An unknown error occurred', originalError: error);
  }
}
