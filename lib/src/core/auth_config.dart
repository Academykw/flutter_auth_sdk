/// Configuration for the Auth SDK
class AuthConfig {
  /// Whether to enable Email/Password authentication
  final bool enableEmailPassword;

  /// Whether to enable Google Sign-In
  final bool enableGoogle;

  /// Whether to enable Apple Sign-In
  final bool enableApple;

  /// Optional: Common configuration for specific providers can be added here
  const AuthConfig({
    this.enableEmailPassword = true,
    this.enableGoogle = false,
    this.enableApple = false,
  });
}
