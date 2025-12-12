# Custom Error UI Implementation Guide

This guide shows you how to customize error handling in your Flutter app using the Firebase Auth SDK.

## 📋 Table of Contents

1. [Error as Dialog Popup](#1-error-as-dialog-popup)
2. [Error as Snackbar](#2-error-as-snackbar)
3. [Error as Bottom Sheet](#3-error-as-bottom-sheet)
4. [Custom Error Banner Widget](#4-custom-error-banner-widget)
5. [Global Error Handler](#5-global-error-handler)
6. [Error as Toast](#6-error-as-toast)
7. [Send Errors to Analytics](#7-send-errors-to-analytics)
8. [Custom Error Page](#8-custom-error-page)

---

## 1. Error as Dialog Popup

Show errors in a dialog with custom icons and actions based on error type.

\`\`\`dart
void _showErrorDialog(BuildContext context, AuthException error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(_getIconForErrorType(error.errorType)),
          const SizedBox(width: 12),
          const Text('Authentication Error'),
        ],
      ),
      content: Text(error.message),
      actions: [
        if (error.errorType == AuthErrorType.networkError)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry logic
            },
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// Usage
try {
  await authService.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on AuthException catch (e) {
  _showErrorDialog(context, e);
}
\`\`\`

---

## 2. Error as Snackbar

Display errors at the bottom of the screen with auto-dismiss.

\`\`\`dart
void _showErrorSnackbar(BuildContext context, AuthException error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(error.message)),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 4),
      action: error.errorType == AuthErrorType.networkError
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {/* retry */},
            )
          : null,
    ),
  );
}
\`\`\`

---

## 3. Error as Bottom Sheet

Show detailed error information in a modal bottom sheet.

\`\`\`dart
void _showErrorBottomSheet(BuildContext context, AuthException error) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(error.message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    ),
  );
}
\`\`\`

---

## 4. Custom Error Banner Widget

Create a reusable animated error banner.

\`\`\`dart
class CustomErrorBanner extends StatelessWidget {
  final AuthException error;
  final VoidCallback? onDismiss;

  const CustomErrorBanner({
    required this.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(error.message)),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

// Usage in your UI
if (_currentError != null)
  CustomErrorBanner(
    error: _currentError!,
    onDismiss: () => setState(() => _currentError = null),
  )
\`\`\`

---

## 5. Global Error Handler

Set up a global error handler that shows errors app-wide.

\`\`\`dart
class GlobalErrorHandlerExample extends StatefulWidget {
  final Widget child;

  const GlobalErrorHandlerExample({required this.child});

  @override
  State<GlobalErrorHandlerExample> createState() => 
      _GlobalErrorHandlerExampleState();
}

class _GlobalErrorHandlerExampleState extends State<GlobalErrorHandlerExample> {
  AuthException? _currentError;

  @override
  void initState() {
    super.initState();
    
    // Set up global callback
    AuthErrorHandler.instance.setGlobalErrorCallback((error) {
      setState(() => _currentError = error);
      
      // Auto-dismiss after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _currentError = null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentError != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomErrorBanner(error: _currentError!),
          ),
      ],
    );
  }
}

// Wrap your app
void main() {
  runApp(
    GlobalErrorHandlerExample(
      child: MyApp(),
    ),
  );
}
\`\`\`

---

## 6. Error as Toast

Create a floating toast notification for errors.

\`\`\`dart
class ErrorAsToastExample {
  static void showErrorToast(BuildContext context, AuthException error) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(error.message, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
  }
}

// Usage
try {
  await authService.signInWithEmailAndPassword(email, password);
} on AuthException catch (e) {
  ErrorAsToastExample.showErrorToast(context, e);
}
\`\`\`

---

## 7. Send Errors to Analytics

Track errors in your analytics platform.

\`\`\`dart
void setupErrorAnalytics() {
  AuthErrorHandler.instance.setGlobalErrorCallback((error) {
    // Log to Firebase Analytics, Sentry, etc.
    FirebaseAnalytics.instance.logEvent(
      name: 'auth_error',
      parameters: error.toJson(),
    );
  });

  // Handle specific error types differently
  AuthErrorHandler.instance.setTypeSpecificHandler(
    AuthErrorType.networkError,
    (error) {
      // Special handling for network errors
      print('Network issue detected: ${error.message}');
    },
  );
}
\`\`\`

---

## 8. Custom Error Page

Navigate to a full-screen error page with complete details.

\`\`\`dart
// Navigate to error page
try {
  await authService.signInWithEmailAndPassword(email, password);
} on AuthException catch (e) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ErrorDetailsPage(error: e),
    ),
  );
}

// Error Details Page shows:
// - Error type and severity
// - Full error message
// - Error code
// - Metadata
// - Stack trace (in debug mode)
// - Action buttons
\`\`\`

---

## 🎨 Customization Tips

### Match Error Type to UI

\`\`\`dart
IconData getIconForErrorType(AuthErrorType type) {
  switch (type) {
    case AuthErrorType.invalidEmail:
      return Icons.email_outlined;
    case AuthErrorType.wrongPassword:
      return Icons.lock_outlined;
    case AuthErrorType.networkError:
      return Icons.wifi_off;
    case AuthErrorType.tooManyRequests:
      return Icons.timer_outlined;
    default:
      return Icons.error_outline;
  }
}

Color getColorForSeverity(ErrorSeverity severity) {
  switch (severity) {
    case ErrorSeverity.critical:
      return Colors.red;
    case ErrorSeverity.high:
      return Colors.orange;
    case ErrorSeverity.medium:
      return Colors.yellow.shade700;
    case ErrorSeverity.low:
      return Colors.blue;
  }
}
\`\`\`

### Add Retry Logic

\`\`\`dart
if (error.errorType == AuthErrorType.networkError) {
  // Show retry button
  ElevatedButton(
    onPressed: () => _retryAuthentication(),
    child: const Text('Retry'),
  );
}
\`\`\`

---

## 🚀 Best Practices

1. **Always show user-friendly messages** - The SDK provides clear error messages
2. **Use different UI for different severities** - Critical errors need more attention
3. **Provide actions when appropriate** - Retry for network errors, reset for password issues
4. **Log errors for debugging** - Use analytics to track auth issues
5. **Test error states** - Use MockAuthService to test error handling
6. **Consider accessibility** - Announce errors to screen readers

---

## 📦 Complete Integration Example

\`\`\`dart
class MyAuthScreen extends StatefulWidget {
  @override
  State<MyAuthScreen> createState() => _MyAuthScreenState();
}

class _MyAuthScreenState extends State<MyAuthScreen> {
  final _authService = FirebaseAuthService();
  AuthException? _currentError;

  Future<void> _handleSignIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Navigate to home
    } on AuthException catch (e) {
      // Choose your preferred error UI method:
      _showErrorDialog(context, e);
      // OR: _showErrorSnackbar(context, e);
      // OR: setState(() => _currentError = e);
      // OR: ErrorAsToastExample.showErrorToast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_currentError != null)
            CustomErrorBanner(
              error: _currentError!,
              onDismiss: () => setState(() => _currentError = null),
            ),
          // Your auth form here
        ],
      ),
    );
  }
}
\`\`\`

---

**You have complete control over how errors are displayed!** Choose the approach that best fits your app's design and user experience.
