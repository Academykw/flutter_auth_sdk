 enum AuthStatus {
  authenticated,
  unauthenticated,
  tokenExpired,
  unknown,
}

class AuthState {
  final AuthStatus status;
  final dynamic user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  factory AuthState.authenticated(dynamic user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.tokenExpired() {
    return const AuthState(status: AuthStatus.tokenExpired);
  }
}
