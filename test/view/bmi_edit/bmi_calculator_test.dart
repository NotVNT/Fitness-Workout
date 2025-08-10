import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/user_model.dart';

void main() {
  group('BMI Calculator Tests', () {
    group('BMI Calculation Tests', () {
      test('should calculate BMI correctly for normal values', () {
        // Arrange
        const height = 170.0; // cm
        const weight = 70.0; // kg
        const expectedBMI = 24.22; // weight / (height/100)^2

        // Act
        final bmi = BMICalculator.calculateBMI(height, weight);

        // Assert
        expect(bmi, closeTo(expectedBMI, 0.01));
      });

      test('should calculate BMI correctly for edge cases', () {
        // Test case 1: Very tall person
        expect(BMICalculator.calculateBMI(200.0, 80.0), closeTo(20.0, 0.01));

        // Test case 2: Very short person
        expect(BMICalculator.calculateBMI(150.0, 60.0), closeTo(26.67, 0.01));

        // Test case 3: High weight
        expect(BMICalculator.calculateBMI(170.0, 100.0), closeTo(34.60, 0.01));

        // Test case 4: Low weight
        expect(BMICalculator.calculateBMI(170.0, 50.0), closeTo(17.30, 0.01));
      });

      test('should handle decimal values correctly', () {
        // Arrange
        const height = 175.5;
        const weight = 72.3;

        // Act
        final bmi = BMICalculator.calculateBMI(height, weight);

        // Assert
        expect(bmi, isA<double>());
        expect(bmi, greaterThan(0));
      });

      test('should throw exception for invalid height', () {
        // Assert
        expect(() => BMICalculator.calculateBMI(0, 70), throwsArgumentError);
        expect(() => BMICalculator.calculateBMI(-10, 70), throwsArgumentError);
      });

      test('should throw exception for invalid weight', () {
        // Assert
        expect(() => BMICalculator.calculateBMI(170, 0), throwsArgumentError);
        expect(() => BMICalculator.calculateBMI(170, -5), throwsArgumentError);
      });
    });

    group('BMI Category Tests', () {
      test('should classify BMI categories correctly', () {
        // Underweight
        expect(BMICalculator.getBMICategory(17.0), equals('Thiếu cân'));
        expect(BMICalculator.getBMICategory(18.4), equals('Thiếu cân'));

        // Normal weight
        expect(BMICalculator.getBMICategory(18.5), equals('Bình thường'));
        expect(BMICalculator.getBMICategory(22.0), equals('Bình thường'));
        expect(BMICalculator.getBMICategory(24.9), equals('Bình thường'));

        // Overweight
        expect(BMICalculator.getBMICategory(25.0), equals('Thừa cân'));
        expect(BMICalculator.getBMICategory(27.0), equals('Thừa cân'));
        expect(BMICalculator.getBMICategory(29.9), equals('Thừa cân'));

        // Obese
        expect(BMICalculator.getBMICategory(30.0), equals('Béo phì'));
        expect(BMICalculator.getBMICategory(35.0), equals('Béo phì'));
        expect(BMICalculator.getBMICategory(40.0), equals('Béo phì'));
      });

      test('should handle boundary values correctly', () {
        // Test exact boundary values
        expect(BMICalculator.getBMICategory(18.5), equals('Bình thường'));
        expect(BMICalculator.getBMICategory(25.0), equals('Thừa cân'));
        expect(BMICalculator.getBMICategory(30.0), equals('Béo phì'));
      });
    });

    group('BMI Color Tests', () {
      test('should return correct colors for BMI categories', () {
        // Underweight - Blue
        expect(BMICalculator.getBMIColor(17.0), equals(BMIColors.underweight));

        // Normal - Green
        expect(BMICalculator.getBMIColor(22.0), equals(BMIColors.normal));

        // Overweight - Orange
        expect(BMICalculator.getBMIColor(27.0), equals(BMIColors.overweight));

        // Obese - Red
        expect(BMICalculator.getBMIColor(32.0), equals(BMIColors.obese));
      });
    });

    group('BMI Recommendations Tests', () {
      test('should provide correct recommendations for each category', () {
        // Underweight
        final underweightRec = BMICalculator.getRecommendation(17.0);
        expect(underweightRec, contains('tăng cân'));
        expect(underweightRec, contains('dinh dưỡng'));

        // Normal
        final normalRec = BMICalculator.getRecommendation(22.0);
        expect(normalRec, contains('duy trì'));
        expect(normalRec, contains('cân nặng hiện tại'));

        // Overweight
        final overweightRec = BMICalculator.getRecommendation(27.0);
        expect(overweightRec, contains('giảm cân'));
        expect(overweightRec, contains('tập thể dục'));

        // Obese
        final obeseRec = BMICalculator.getRecommendation(32.0);
        expect(obeseRec, contains('giảm cân'));
        expect(obeseRec, contains('bác sĩ'));
      });
    });

    group('Ideal Weight Calculation Tests', () {
      test('should calculate ideal weight range correctly', () {
        // Arrange
        const height = 170.0;

        // Act
        final idealRange = BMICalculator.getIdealWeightRange(height);

        // Assert
        expect(idealRange['min'], closeTo(53.5, 0.1)); // BMI 18.5
        expect(idealRange['max'], closeTo(72.2, 0.1)); // BMI 25.0
      });

      test('should calculate ideal weight for different heights', () {
        // Test for 160cm
        final range160 = BMICalculator.getIdealWeightRange(160.0);
        expect(range160['min'], closeTo(47.4, 0.1));
        expect(range160['max'], closeTo(64.0, 0.1));

        // Test for 180cm
        final range180 = BMICalculator.getIdealWeightRange(180.0);
        expect(range180['min'], closeTo(59.9, 0.1));
        expect(range180['max'], closeTo(81.0, 0.1));
      });
    });

    group('BMI Progress Tracking Tests', () {
      test('should calculate BMI change correctly', () {
        // Arrange
        const height = 170.0;
        const oldWeight = 80.0;
        const newWeight = 75.0;

        // Act
        final oldBMI = BMICalculator.calculateBMI(height, oldWeight);
        final newBMI = BMICalculator.calculateBMI(height, newWeight);
        final change = BMICalculator.calculateBMIChange(oldBMI, newBMI);

        // Assert
        expect(change, closeTo(-1.73, 0.01)); // Negative means improvement
      });

      test('should determine if BMI improved', () {
        // From overweight to normal
        expect(BMICalculator.isBMIImproved(27.0, 23.0), isTrue);

        // From normal to overweight
        expect(BMICalculator.isBMIImproved(23.0, 27.0), isFalse);

        // From underweight to normal
        expect(BMICalculator.isBMIImproved(17.0, 20.0), isTrue);

        // No change
        expect(BMICalculator.isBMIImproved(22.0, 22.0), isFalse);
      });
    });

    group('UserModel BMI Extension Tests', () {
      test('should calculate BMI from UserModel correctly', () {
        // Arrange
        final user = UserModel(
          id: 'test',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          height: 170.0,
          weight: 70.0,
        );

        // Act
        final bmi = user.bmi;

        // Assert
        expect(bmi, closeTo(24.22, 0.01));
      });

      test('should return 0.0 BMI when height or weight is missing', () {
        // Test missing height (default 0.0)
        final userNoHeight = UserModel(
          id: 'test',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          weight: 70.0,
          // height defaults to 0.0
        );
        expect(userNoHeight.bmi, equals(0.0));

        // Test missing weight (default 0.0)
        final userNoWeight = UserModel(
          id: 'test',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          height: 170.0,
          // weight defaults to 0.0
        );
        expect(userNoWeight.bmi, equals(0.0));
      });

      test('should get BMI category from UserModel', () {
        // Arrange
        final user = UserModel(
          id: 'test',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          height: 170.0,
          weight: 70.0,
        );

        // Act
        final category = user.bmiCategory;

        // Assert
        expect(
            category, equals('Normal')); // UserModel returns English categories
      });
    });
  });
}

// BMI Calculator utility class for testing
class BMICalculator {
  static double calculateBMI(double height, double weight) {
    if (height <= 0 || weight <= 0) {
      throw ArgumentError('Height and weight must be positive values');
    }

    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25.0) return 'Bình thường';
    if (bmi < 30.0) return 'Thừa cân';
    return 'Béo phì';
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return BMIColors.underweight;
    if (bmi < 25.0) return BMIColors.normal;
    if (bmi < 30.0) return BMIColors.overweight;
    return BMIColors.obese;
  }

  static String getRecommendation(double bmi) {
    if (bmi < 18.5) {
      return 'Bạn cần tăng cân. Hãy tăng cường dinh dưỡng và tập thể dục phù hợp.';
    }
    if (bmi < 25.0) {
      return 'Cân nặng của bạn bình thường. Hãy duy trì cân nặng hiện tại.';
    }
    if (bmi < 30.0) {
      return 'Bạn cần giảm cân. Hãy tập thể dục thường xuyên và ăn uống lành mạnh.';
    }
    return 'Bạn cần giảm cân nghiêm túc. Nên tham khảo ý kiến bác sĩ.';
  }

  static Map<String, double> getIdealWeightRange(double height) {
    final heightInMeters = height / 100;
    return {
      'min': 18.5 * heightInMeters * heightInMeters,
      'max': 25.0 * heightInMeters * heightInMeters,
    };
  }

  static double calculateBMIChange(double oldBMI, double newBMI) {
    return newBMI - oldBMI;
  }

  static bool isBMIImproved(double oldBMI, double newBMI) {
    const idealBMI = 22.0;
    final oldDistance = (oldBMI - idealBMI).abs();
    final newDistance = (newBMI - idealBMI).abs();
    return newDistance < oldDistance;
  }
}

// BMI Colors
class BMIColors {
  static const Color underweight = Color(0xFF3498DB); // Blue
  static const Color normal = Color(0xFF2ECC71); // Green
  static const Color overweight = Color(0xFFF39C12); // Orange
  static const Color obese = Color(0xFFE74C3C); // Red
}

// UserModel already has bmi and bmiCategory methods implemented
