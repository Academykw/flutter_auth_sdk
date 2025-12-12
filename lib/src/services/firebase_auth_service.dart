import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/auth_config.dart';
import '../core/auth_exception.dart' as app_exception;
import '../core/auth_state.dart';
import '../core/auth_validator.dart';
import '../core/auth_error_handler.dart';
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
      return AuthState.authenticated(user);
    }
    return AuthState.unauthenticated();
  }

  @override
  Future<void> initialize(AuthConfig config) async {}

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  }) async {
    AuthValidator.validateEmail(email);

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      final authException = _mapFirebaseError(e, stackTrace);
      if (errorHandler != null) {
        errorHandler.handleError(authException);
        if (errorHandler.shouldRethrow) {
          throw authException;
        }
      } else {
        throw authException;
      }
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    AuthErrorHandler? errorHandler,
  }) async {
    AuthValidator.validateEmail(email);
    AuthValidator.validatePassword(password);

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      final authException = _mapFirebaseError(e, stackTrace);
      if (errorHandler != null) {
        errorHandler.handleError(authException);
        if (errorHandler.shouldRethrow) {
          throw authException;
        }
      } else {
        throw authException;
      }
    }
  }

  @override
  Future<void> signInWithGoogle({
    AuthErrorHandler? errorHandler,
  }) async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } catch (e, stackTrace) {
      final authException = _mapFirebaseError(e, stackTrace);
      if (errorHandler != null) {
        errorHandler.handleError(authException);
        if (errorHandler.shouldRethrow) {
          throw authException;
        }
      } else {
        throw authException;
      }
    }
  }

  @override
  Future<void> signInWithApple({
    AuthErrorHandler? errorHandler,
  }) async {
    throw UnimplementedError(
        'Apple Sign In not yet implemented in this version.');
  }

  @override
  Future<void> signOut({
    AuthErrorHandler? errorHandler,
  }) async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.disconnect(),
      ]);
    } catch (e, stackTrace) {
      final authException = _mapFirebaseError(e, stackTrace);
      if (errorHandler != null) {
        errorHandler.handleError(authException);
        if (errorHandler.shouldRethrow) {
          throw authException;
        }
      } else {
        throw authException;
      }
    }
  }

  @override
  Future<AuthResult<void>> signInWithEmailAndPasswordResult({
    required String email,
    required String password,
  }) async {
    try {
      await signInWithEmailAndPassword(email: email, password: password);
      return const AuthResult.success(null);
    } on app_exception.AuthException catch (e) {
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
    } on app_exception.AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  @override
  Future<AuthResult<void>> signInWithGoogleResult() async {
    try {
      await signInWithGoogle();
      return const AuthResult.success(null);
    } on app_exception.AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  @override
  Future<AuthResult<void>> signInWithAppleResult() async {
    try {
      await signInWithApple();
      return const AuthResult.success(null);
    } on app_exception.AuthException catch (e) {
      return AuthResult.failure(e);
    }
  }

  app_exception.AuthException _mapFirebaseError(
    dynamic error,
    StackTrace stackTrace,
  ) {
    if (error is FirebaseAuthException) {
      final metadata = {
        'firebaseCode': error.code,
        'firebaseMessage': error.message,
        'email': error.email,
        'credential': error.credential?.toString(),
      };

      switch (error.code) {
        case 'user-not-found':
          return app_exception.UserNotFoundException(
            message: error.message,
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        case 'wrong-password':
          return app_exception.InvalidCredentialsException(
            message: error.message,
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        case 'invalid-email':
          return app_exception.InvalidCredentialsException(
            message: 'Invalid email address.',
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        case 'email-already-in-use':
          return app_exception.EmailAlreadyInUseException(
            message: 'The account already exists for that email.',
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        case 'weak-password':
          return app_exception.WeakPasswordException(
            message: error.message,
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        case 'network-request-failed':
          return app_exception.NetworkException(
            message: error.message,
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
        default:
          return app_exception.AuthUnknownException(
            error.message ?? 'Unknown error',
            originalError: error,
            metadata: metadata,
            stackTrace: stackTrace,
          );
      }
    }
    return app_exception.AuthUnknownException(
      'An unknown error occurred',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
