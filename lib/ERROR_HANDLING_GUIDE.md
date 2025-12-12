# Error Handling Guide

This SDK provides flexible error handling that gives developers complete control over how they handle authentication errors.

## Key Features

### 1. Rich Error Information
Every `AuthException` provides:
- `message` - User-friendly error message
- `code` - Machine-readable error code
- `errorType` - Enum for programmatic error handling
- `severity` - Error severity level (info, warning, error, critical)
- `originalError` - The original platform error
- `metadata` - Additional context (Firebase codes, email, etc.)
- `stackTrace` - Full stack trace for debugging

### 2. Error Types
\`\`\`dart
enum AuthErrorType {
  invalidCredentials,
  invalidEmail,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  shortPassword,
  tokenExpired,
  network,
  validation,
  unknown,
}
\`\`\`

### 3. Error Severity Levels
\`\`\`dart
enum AuthErrorSeverity {
  info,      // Informational
  warning,   // User error, recoverable
  error,     // System error, might be recoverable
  critical,  // Critical failure, likely unrecoverable
}
\`\`\`

## Usage Patterns

### Pattern 1: Traditional Try-Catch
\`\`\`dart
try {
  await authService.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on InvalidCredentialsException catch (e) {
  // Handle invalid credentials
  print(e.message);
  print(e.errorType);
  print(e.metadata);
} on NetworkException catch (e) {
  // Handle network errors
} on AuthException catch (e) {
  // Handle any other auth error
}
\`\`\`

### Pattern 2: Centralized Error Handler
\`\`\`dart
final errorHandler = AuthErrorHandler(
  onError: (error) {
    // Centralized error handling
    showSnackbar(error.message);
  },
  logger: (error, stackTrace) {
    // Custom logging
    print('Error: ${error.message}');
  },
  shouldRethrow: true,
);

await authService.signInWithEmailAndPassword(
  email: email,
  password: password,
  errorHandler: errorHandler,
);
\`\`\`

### Pattern 3: Type-Specific Handlers
\`\`\`dart
final errorHandler = AuthErrorHandler(
  errorTypeHandlers: {
    AuthErrorType.invalidCredentials: (error) {
      showDialog('Wrong password');
    },
    AuthErrorType.network: (error) {
      showRetryDialog();
    },
  },
);
\`\`\`

### Pattern 4: Result-Based (No Exceptions)
\`\`\`dart
final result = await authService.signInWithEmailAndPasswordResult(
  email: email,
  password: password,
);

result.when(
  success: (_) => navigateToHome(),
  failure: (error) => showError(error.message),
);

// Or
if (result.isSuccess) {
  // Success
} else {
  // Handle result.error
}
\`\`\`

### Pattern 5: Silent Error Handling
\`\`\`dart
final errorHandler = AuthErrorHandler.silent(
  onError: (error) => logError(error),
);

// Won't throw, just logs
await authService.signInWithEmailAndPassword(
  email: email,
  password: password,
  errorHandler: errorHandler,
);
\`\`\`

## Useful Error Properties

\`\`\`dart
catch (e) on AuthException {
  // Check if error is recoverable
  if (e.isRecoverable) {
    showRetryButton();
  }
  
  // Check if it's a network issue
  if (e.isNetworkRelated) {
    scheduleRetry();
  }
  
  // Check if it's a validation error
  if (e.isValidationError) {
    highlightFormField();
  }
  
  // Check severity
  if (e.severity == AuthErrorSeverity.critical) {
    alertSupport();
  }
  
  // Access metadata
  print(e.metadata); // Firebase codes, email, etc.
  
  // Serialize to JSON
  await analytics.log(e.toJson());
}
\`\`\`

## Best Practices

1. **Use specific catch blocks** for errors you want to handle differently
2. **Use AuthErrorHandler** for centralized error handling across your app
3. **Use Result pattern** if you prefer functional error handling without exceptions
4. **Check error properties** like `isRecoverable`, `isNetworkRelated` for smart retry logic
5. **Log error metadata** for debugging - includes original Firebase errors and context
6. **Transform errors** using `errorTransformer` to customize messages for your users
7. **Use type-specific handlers** to provide contextual error handling

## Migration from Basic Error Handling

Before:
\`\`\`dart
try {
  await authService.signIn(email, password);
} catch (e) {
  showError('Login failed');
}
\`\`\`

After (with full control):
\`\`\`dart
try {
  await authService.signIn(email, password);
} on InvalidCredentialsException catch (e) {
  showError('Wrong email or password');
  logAnalytics('invalid_login', e.metadata);
} on NetworkException catch (e) {
  showRetryDialog();
  scheduleRetry();
} on AuthException catch (e) {
  showError(e.message);
  reportToSentry(e.toJson(), e.stackTrace);
}
