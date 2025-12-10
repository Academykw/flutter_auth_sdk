# Firebase Setup Guide

To use this SDK with a real Firebase project, follow these steps to configure your application.

## 1. Create a Firebase Project

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project** and follow the prompts.

## 2. Register Your App

### Android
1.  In the Firebase Project Overview, click the **Android** icon.
2.  Enter your package name (e.g., `com.example.yourapp`).
3.  Click **Register app**.
4.  Download `google-services.json`.
5.  Place this file in your app's `android/app/` directory.

### iOS
1.  In the Firebase Project Overview, click the **iOS** icon.
2.  Enter your bundle ID.
3.  Click **Register app**.
4.  Download `GoogleService-Info.plist`.
5.  Place this file in your app's `ios/Runner/` directory (open Xcode and drag it in to ensure it's added to the target).

## 3. Add Firebase Config to Your App

**Note**: The SDK itself handles the logic, but **your app** must provide the configuration files and initialize Firebase.

### Add Dependencies

In your app's `pubspec.yaml`, ensure you have:

```yaml
dependencies:
  firebase_core: ^2.17.0
  flutter_firebase_auth_sdk:
    path: path/to/sdk # or git url
```

### Initialize Firebase

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_auth_sdk/flutter_firebase_auth_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (uses the config files you added)
  await Firebase.initializeApp();

  runApp(const MyApp());
}
```

## 4. Use Real Auth Service

When using the SDK widgets, pass `FirebaseAuthService()` instead of `MockAuthService`.

```dart

AuthScreen(
  config: AuthConfig(
    enableEmailPassword: true,
    enableGoogle: true,
  ),
  // Use the real service
  authService: FirebaseAuthService(), 
  onAuthSuccess: () {
    print("Logged in with real Firebase!");
  },
);
```

## 5. Enable Providers in Console

Don't forget to go to **Authentication > Sign-in method** in the Firebase Console and enable:
*   Email/Password
*   Google (requires SHA-1 fingerprint for Android)
*   Apple (requires Apple Developer Account)
