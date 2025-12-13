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
  arc_firebase_auth_sdk: ^0.0.1

```

2.  (Optional) For full Firebase support, ensure you have configured your Flutter app with Firebase:
    *   [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
    *   See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for a step-by-step guide on connecting this SDK to your Firebase project.

## Usage

### 1. Default Mode (Pre-built UI)
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

// ### 2. Headless Mode (Custom UI)

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
##  Flexible Error Handling - Your Way!
This SDK gives you **complete control** over how you handle authentication errors. 
Every error includes rich metadata so you can customize your error handling exactly how you want.

### What You Get With Every Error

```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  // Access rich error information
  print(e.errorType);        // AuthErrorType enum (invalid_email, weak_password, etc.)
  print(e.severity);         // AuthErrorSeverity (critical, error, warning, info)
  print(e.message);          // User-friendly message
  print(e.code);             // Error code for programmatic handling
  print(e.originalError);    // Original Firebase error
  print(e.metadata);         // Additional context
  print(e.stackTraceString); // Full stack trace
}
```
### Handle Errors YOUR Way
**1. Show a Dialog**

```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Authentication Error'),
      content: Text(e.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```
**2. Show a Snackbar**
```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.message),
      backgroundColor: e.severity == AuthErrorSeverity.critical
        ? Colors.red
        : Colors.orange,
    ),
  );
}
```

**3. Show a Bottom Sheet**
```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(e.message, style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    ),
  );
}
```

**4. Custom Toast/Banner**
```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  // Use your favorite toast library
  Fluttertoast.showToast(
    msg: e.message,
    backgroundColor: e.severity == AuthErrorSeverity.critical ? Colors.red : Colors.orange,
  );
}
```

**5. Navigate to Error Page**
```dart
try {
  await authService.signInWithEmail(email: email, password: password);
} on AuthException catch (e) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ErrorPage(exception: e),
    ),
  );
}
```
