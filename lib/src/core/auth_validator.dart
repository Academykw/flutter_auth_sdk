import 'auth_exception.dart';

class AuthValidator {
  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw const InvalidEmailException(message: 'Email cannot be empty.');
    }
    // Strict regex enforcing domain extension
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      throw const InvalidEmailException(message: 'Invalid email address format.');
    }
  }

  static void validatePassword(String password) {
    if (password.length < 6) {
      throw const ShortPasswordException(message: 'Password must be at least 6 characters.');
    }
    
    // Must contain at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
       throw const WeakPasswordException(message: 'Password must contain at least one uppercase letter.');
    }

    // Simple heuristic for weak passwords: "password", "123456", or all same characters
    final weakPatterns = ['password', '123456', 'qwerty'];
    if (weakPatterns.contains(password.toLowerCase()) || 
        RegExp(r'^(.)\1+$').hasMatch(password)) {
       throw const WeakPasswordException(message: 'Password is too weak. Try a stronger one.');
    }
  }
}
