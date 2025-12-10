# Flutter Firebase Auth SDK

A reusable Authentication SDK powered by Firebase that supports both a pre-built UI and a no-UI mode for custom implementation.

## Features

*   **Dual Mode UI**:
    *   **Default Mode**: Plug-and-play `AuthScreen` widget.
    *   **Headless Mode**: Exposed `AuthService` and streams for building custom UIs.
*   **Unified Error Handling**: Maps Firebase errors to custom exceptions (`UserNotFoundException`, `InvalidCredentialsException`, etc.).
*   **Configurable**: Enable/disable providers via `AuthConfig`.
*   **State Management**: Built-in streams for `Authenticated`, `Unauthenticated`, `TokenExpired`.

## Installation

1.  Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_firebase_auth_sdk:
    path: path/to/flutter_firebase_auth_sdk
```

2.  (Optional) For full Firebase support, ensure you have configured your Flutter app with Firebase:
    *   [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)

## Usage

### 1. Default Mode (Pre-built UI)

```dart
import 'package:flutter_firebase_auth_sdk/flutter_firebase_auth_sdk.dart';

// ...

AuthScreen(
  config: AuthConfig(
    enableEmailPassword: true,
    enableGoogle: true,
    enableApple: true,
  ),
  authService: FirebaseAuthService(), // Or MockAuthService() for testing
  onAuthSuccess: () {
    print("User authenticated!");
  },
);
```

### 2. Headless Mode (Custom UI)

```dart
final authService = FirebaseAuthService();

// Sign In
try {
  await authService.signInWithEmailAndPassword(
    email: 'test@example.com', 
    password: 'password'
  );
} on AuthException catch (e) {
  print(e.message);
}

// Listen to state
StreamBuilder<AuthState>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.data?.status == AuthStatus.authenticated) {
      return HomePage();
    }
    return LoginPage();
  },
);
```

## Error Handling

The SDK maps Firebase errors to specific exceptions:

*   `InvalidCredentialsException`: Wrong email/password.
*   `UserNotFoundException`: User does not exist.
*   `EmailAlreadyInUseException`: Email already registered.
*   `WeakPasswordException`: Password is too weak.
*   `NetworkException`: Network connectivity issues.

##Screenshot


<img width="75" height="150" alt="pc1" src="https://github.com/user-attachments/assets/365fdafb-806c-45c9-91fe-87a207a7784f?raw=true" />
<img width="85" height="153" alt="pc2" src="https://github.com/user-attachments/assets/491280a4-c375-4c26-b9cb-30f54fe4af92?raw=true" />
<img width="89" height="151" alt="pc3" src="https://github.com/user-attachments/assets/feede630-104c-422e-85bc-d2e4a86fa1dc?raw=true" />



