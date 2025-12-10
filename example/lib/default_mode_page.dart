import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_sdk/flutter_firebase_auth_sdk.dart';

class DefaultModePage extends StatefulWidget {
  const DefaultModePage({super.key});

  @override
  State<DefaultModePage> createState() => _DefaultModePageState();
}

class _DefaultModePageState extends State<DefaultModePage> {

  final AuthService _authService = MockAuthService();
  

  final AuthConfig _authConfig = const AuthConfig(
    enableEmailPassword: true,
    enableGoogle: true,
    enableApple: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Default UI Mode'),
      ),
      body: StreamBuilder<AuthState>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          final state = snapshot.data;
          
          if (state?.status == AuthStatus.authenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text('Signed In! User: ${state?.user}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _authService.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          }

          return AuthScreen(
            config: _authConfig,
            authService: _authService,
            onAuthSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication Successful!')),
              );
            },
          );
        },
      ),
    );
  }
}
//