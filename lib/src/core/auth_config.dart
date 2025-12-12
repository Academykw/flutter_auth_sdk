class AuthConfig {

  final bool enableEmailPassword;


  final bool enableGoogle;


  final bool enableApple;


  
  const AuthConfig({
    this.enableEmailPassword = true,
    this.enableGoogle = false,
    this.enableApple = false,
  });
}
