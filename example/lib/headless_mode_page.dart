import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_sdk/flutter_firebase_auth_sdk.dart';

class HeadlessModePage extends StatefulWidget {
  const HeadlessModePage({super.key});

  @override
  State<HeadlessModePage> createState() => _HeadlessModePageState();
}

class _HeadlessModePageState extends State<HeadlessModePage> {
  final AuthService _authService = MockAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _statusMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _statusMessage = "Sign In Call Completed";
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.message}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _statusMessage = "Sign Up Call Completed";
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.message}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Headless Mode')),
      body: StreamBuilder<AuthState>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final isAuthenticated = state?.status == AuthStatus.authenticated;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade200,
                    child: Text('Current State: ${state?.status.name}\nUser: ${state?.user ?? "None"}'),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_statusMessage!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  if (isAuthenticated) ...[
                    ElevatedButton(
                      onPressed: () => _authService.signOut(),
                      child: const Text('Sign Out'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            child: _isLoading ? const CircularProgressIndicator() : const Text('Custom Sign In'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () {
                              _authService.signInWithGoogle();
                            },
                            child: const Text('Custom Google'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Custom Sign Up'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Mock Credentials: test@example.com / password',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
