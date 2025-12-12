import 'package:flutter/material.dart';
import '../src/core/auth_exception.dart';
import '../src/core/auth_error_handler.dart';
import '../src/services/auth_service_contract.dart';

 // Example 1: Display Errors as Dialog Popups
class ErrorAsDialogExample extends StatelessWidget {
  final AuthService authService;

  const ErrorAsDialogExample({super.key, required this.authService});

  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, e);
      }
    }
  }

  void _showErrorDialog(BuildContext context, AuthException error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForErrorType(error.errorType),

            ),
            const SizedBox(width: 12),
            const Text('Authentication Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            const SizedBox(height: 8),
            Text(
              'Error Type: ${error.errorType.name}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (error.errorType == AuthErrorType.networkError)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry logic here
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

  IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidEmail:
        return Icons.email_outlined;
      case AuthErrorType.wrongPassword:
        return Icons.lock_outlined;
      case AuthErrorType.userNotFound:
        return Icons.person_off_outlined;
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.tooManyRequests:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// Example 2: Display Errors as Snackbars
class ErrorAsSnackbarExample extends StatelessWidget {
  final AuthService authService;

  const ErrorAsSnackbarExample({super.key, required this.authService});

  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, e);
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, AuthException error) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIconForErrorType(error.errorType),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(error.message)),
        ],
      ),

      duration: const Duration(seconds: 4),
      action: error.errorType == AuthErrorType.networkError
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry logic
              },
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.tooManyRequests:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
// Example 3: Display Errors in a Bottom Sheet
class ErrorAsBottomSheetExample extends StatelessWidget {
  final AuthService authService;

  const ErrorAsBottomSheetExample({super.key, required this.authService});

  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (context.mounted) {
        _showErrorBottomSheet(context, e);
      }
    }
  }

  void _showErrorBottomSheet(BuildContext context, AuthException error) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForErrorType(error.errorType),

                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Authentication Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Type: ${error.errorType.name} | Severity: ${error.severity.name}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (error.errorType == AuthErrorType.networkError)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Retry logic
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                if (error.errorType == AuthErrorType.networkError)
                  const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidEmail:
        return Icons.email_outlined;
      case AuthErrorType.wrongPassword:
        return Icons.lock_outlined;
      case AuthErrorType.userNotFound:
        return Icons.person_off_outlined;
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.tooManyRequests:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


// Example 4: Custom Error Banner Widget
class CustomErrorBanner extends StatefulWidget {
  final AuthException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const CustomErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  State<CustomErrorBanner> createState() => _CustomErrorBannerState();
}

class _CustomErrorBannerState extends State<CustomErrorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(

          border: Border.all(

            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForErrorType(widget.error.errorType),

              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.error.errorType.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.error.message),
                ],
              ),
            ),
            if (widget.error.errorType == AuthErrorType.networkError &&
                widget.onRetry != null)
              IconButton(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                tooltip: 'Retry',
              ),
            IconButton(
              onPressed: widget.onDismiss,
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidEmail:
        return Icons.email_outlined;
      case AuthErrorType.wrongPassword:
        return Icons.lock_outlined;
      case AuthErrorType.userNotFound:
        return Icons.person_off_outlined;
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.tooManyRequests:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }


}



// Example 5: Error Handling with Custom Toast
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
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForErrorType(error.errorType),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => overlayEntry.remove(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  static IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.tooManyRequests:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }


}


