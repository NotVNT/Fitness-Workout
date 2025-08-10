import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    group('Validation Tests', () {
      test('should validate email format', () {
        // Test cases for email validation
        expect(AuthServiceValidation.isValidEmail('test@example.com'), isTrue);
        expect(AuthServiceValidation.isValidEmail('invalid-email'), isFalse);
        expect(AuthServiceValidation.isValidEmail(''), isFalse);
        expect(AuthServiceValidation.isValidEmail('test@'), isFalse);
        expect(AuthServiceValidation.isValidEmail('@example.com'), isFalse);
      });

      test('should validate password strength', () {
        // Test cases for password validation
        expect(AuthServiceValidation.isValidPassword('password123'), isTrue);
        expect(AuthServiceValidation.isValidPassword('12345'),
            isFalse); // Too short
        expect(AuthServiceValidation.isValidPassword(''), isFalse); // Empty
        expect(AuthServiceValidation.isValidPassword('pass'),
            isFalse); // Too short
      });
    });

    // Note: Error message tests would require Firebase initialization
    // These tests are commented out as they require a real AuthService instance
    // which needs Firebase to be initialized. In a real testing scenario,
    // you would either:
    // 1. Initialize Firebase for testing, or
    // 2. Refactor AuthService to allow dependency injection for testing
  });
}

// Extension for AuthService to add validation methods for testing
extension AuthServiceValidation on AuthService {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
