import 'package:flutter_test/flutter_test.dart';

/// Setup Firebase for testing
class FirebaseTestSetup {
  static bool _isInitialized = false;

  /// Initialize Firebase for testing
  static Future<void> setupFirebase() async {
    if (_isInitialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();
    _isInitialized = true;

    // For unit tests, we don't actually initialize Firebase
    // Instead, we rely on mocking in individual test files
    // This setup is mainly for ensuring test environment is ready
  }

  /// Reset Firebase state for testing
  static Future<void> resetFirebase() async {
    _isInitialized = false;
  }
}
