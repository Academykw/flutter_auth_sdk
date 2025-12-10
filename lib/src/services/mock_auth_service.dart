

import 'dart:async';

import '../../flutter_firebase_auth_sdk.dart';

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
     await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockUsers.containsKey(email)) {
      if (_mockUsers[email] == password) {
        _updateState(AuthState.authenticated({'email': email, 'uid': 'mock-uid-123'}));
        return;
      } else {
        throw const InvalidCredentialsException(message: 'Wrong password provided for that user.');
      }
    } else {
      throw const UserNotFoundException(message: 'No user found for that email.');
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockUsers.containsKey(email)) {
      throw const EmailAlreadyInUseException();
    }
    
    if (password.length < 6) {
      throw const WeakPasswordException(message: 'Password must be at least 6 characters.');
    }

    _mockUsers[email] = password;
    _updateState(AuthState.authenticated({'email': email, 'uid': 'mock-uid-new-${DateTime.now().millisecondsSinceEpoch}'}));
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _updateState(AuthState.authenticated({'email': 'google-user@example.com', 'displayName': 'Google User', 'uid': 'mock-google-uid'}));
  }

  @override
  Future<void> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _updateState(AuthState.authenticated({'email': 'apple-user@example.com', 'displayName': 'Apple User', 'uid': 'mock-apple-uid'}));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _updateState(AuthState.unauthenticated());
  }

  void _updateState(AuthState newState) {
    _currentUser = newState;
    _authStateController.add(newState);
  }
}