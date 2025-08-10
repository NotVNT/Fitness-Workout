import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'services/auth_service_test.dart' as auth_service_tests;
// import 'services/workout_generator_service_test.dart' as workout_generator_tests; // File not found
import 'view/login/login_view_test.dart' as login_view_tests;
import 'view/login/signup_view_test.dart' as signup_view_tests;
import 'view/on_boarding/on_boarding_view_test.dart' as onboarding_tests;
import 'view/bmi_edit/bmi_calculator_test.dart' as bmi_calculator_tests;
import 'view/bmi_edit/height_input_view_test.dart' as height_input_tests;
import 'view/bmi_edit/weight_input_test.dart' as weight_input_tests;

void main() {
  group('Fitness App Test Suite', () {
    group('🔐 Authentication Tests', () {
      auth_service_tests.main();
    });

    // group('🏋️ Workout Generator Tests', () {
    //   workout_generator_tests.main();
    // }); // Commented out - file not found

    group('📱 Login View Tests', () {
      login_view_tests.main();
    });

    group('📝 Signup View Tests', () {
      signup_view_tests.main();
    });

    group('🎯 Onboarding Tests', () {
      onboarding_tests.main();
    });

    group('📊 BMI Calculator Tests', () {
      bmi_calculator_tests.main();
    });

    group('📏 Height Input Tests', () {
      height_input_tests.main();
    });

    group('⚖️ Weight Input Tests', () {
      weight_input_tests.main();
    });
  });
}

// Test utilities and helpers
class TestUtils {
  /// Create a test user with default values
  static Map<String, dynamic> createTestUser({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    double? height,
    double? weight,
    double? targetWeight,
    String? goal,
  }) {
    return {
      'id': id ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email ?? 'test@example.com',
      'firstName': firstName ?? 'Test',
      'lastName': lastName ?? 'User',
      'height': height ?? 170.0,
      'weight': weight ?? 70.0,
      'targetWeight': targetWeight ?? 65.0,
      'goal': goal ?? 'lose_weight',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  /// Create test workout data
  static Map<String, dynamic> createTestWorkout({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? status,
    String? workoutType,
  }) {
    return {
      'id': id ?? 'test_workout_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId ?? 'test_user',
      'name': name ?? 'Test Workout',
      'description': description ?? 'Test workout description',
      'exercises': [],
      'startTime': DateTime.now(),
      'status': status ?? 'planned',
      'workoutType': workoutType ?? 'mixed',
    };
  }

  /// Create test exercise data
  static Map<String, dynamic> createTestExercise({
    String? id,
    String? name,
    String? description,
    int? duration,
    double? caloriesPerMinute,
    List<String>? muscleGroups,
    String? difficulty,
  }) {
    return {
      'id': id ?? 'test_exercise_${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test Exercise',
      'description': description ?? 'Test exercise description',
      'duration': duration ?? 300,
      'caloriesPerMinute': caloriesPerMinute ?? 5.0,
      'muscleGroups': muscleGroups ?? ['Toàn thân'],
      'difficulty': difficulty ?? 'Dễ',
    };
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Calculate BMI
  static double calculateBMI(double height, double weight) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25.0) return 'Bình thường';
    if (bmi < 30.0) return 'Thừa cân';
    return 'Béo phì';
  }

  /// Generate random test data
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          DateTime.now().millisecondsSinceEpoch % chars.length,
        ),
      ),
    );
  }

  /// Wait for animations to complete
  static Future<void> waitForAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Simulate network delay
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Test constants
class TestConstants {
  // Default test values
  static const String defaultEmail = 'test@example.com';
  static const String defaultPassword = 'password123';
  static const String defaultFirstName = 'Test';
  static const String defaultLastName = 'User';
  static const double defaultHeight = 170.0;
  static const double defaultWeight = 70.0;
  static const double defaultTargetWeight = 65.0;
  static const String defaultGoal = 'lose_weight';

  // BMI ranges
  static const double underweightBMI = 17.0;
  static const double normalBMI = 22.0;
  static const double overweightBMI = 27.0;
  static const double obeseBMI = 32.0;

  // Validation limits
  static const double minHeight = 100.0;
  static const double maxHeight = 220.0;
  static const double minWeight = 30.0;
  static const double maxWeight = 200.0;

  // Test timeouts
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration mediumTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);

  // Error messages
  static const String invalidEmailError = 'Email không hợp lệ';
  static const String weakPasswordError = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const String emptyFieldError = 'Trường này không được để trống';
  static const String termsNotAcceptedError =
      'Vui lòng đồng ý với điều khoản sử dụng';
}

// Test matchers
class TestMatchers {
  /// Matcher for valid email format
  static Matcher get isValidEmail => predicate<String>(
        (email) => TestUtils.isValidEmail(email),
        'is a valid email',
      );

  /// Matcher for valid password
  static Matcher get isValidPassword => predicate<String>(
        (password) => TestUtils.isValidPassword(password),
        'is a valid password',
      );

  /// Matcher for valid BMI range
  static Matcher get isValidBMI => predicate<double>(
        (bmi) => bmi > 0 && bmi < 100,
        'is a valid BMI',
      );

  /// Matcher for valid height range
  static Matcher get isValidHeight => predicate<double>(
        (height) =>
            height >= TestConstants.minHeight &&
            height <= TestConstants.maxHeight,
        'is a valid height',
      );

  /// Matcher for valid weight range
  static Matcher get isValidWeight => predicate<double>(
        (weight) =>
            weight >= TestConstants.minWeight &&
            weight <= TestConstants.maxWeight,
        'is a valid weight',
      );
}
