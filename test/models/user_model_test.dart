import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        id: 'user123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: '1990-01-15',
        gender: 'Nam',
        phone: '0123456789',
        weight: 70.0,
        height: 175.0,
        targetWeight: 65.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    group('Constructor Tests', () {
      test('should create UserModel with all required fields', () {
        // Assert
        expect(testUser.id, equals('user123'));
        expect(testUser.email, equals('test@example.com'));
        expect(testUser.firstName, equals('John'));
        expect(testUser.lastName, equals('Doe'));
        expect(testUser.dateOfBirth, equals('1990-01-15'));
        expect(testUser.gender, equals('Nam'));
        expect(testUser.phone, equals('0123456789'));
        expect(testUser.weight, equals(70.0));
        expect(testUser.height, equals(175.0));
        expect(testUser.targetWeight, equals(65.0));
      });

      test('should create UserModel with default values', () {
        // Arrange & Act
        final minimalUser = UserModel(
          id: 'user456',
          email: 'minimal@example.com',
        );

        // Assert
        expect(minimalUser.id, equals('user456'));
        expect(minimalUser.email, equals('minimal@example.com'));
        expect(minimalUser.firstName, equals(''));
        expect(minimalUser.lastName, equals(''));
        expect(minimalUser.dateOfBirth, equals(''));
        expect(minimalUser.gender, equals(''));
        expect(minimalUser.phone, equals(''));
        expect(minimalUser.weight, equals(0.0));
        expect(minimalUser.height, equals(0.0));
        expect(minimalUser.targetWeight, equals(0.0));
        expect(minimalUser.createdAt, isNull);
        expect(minimalUser.updatedAt, isNull);
      });
    });

    group('Computed Properties Tests', () {
      test('should return correct full name', () {
        // Act & Assert
        expect(testUser.fullName, equals('John Doe'));
      });

      test('should handle empty names correctly', () {
        // Arrange
        final userWithoutNames = UserModel(
          id: 'user789',
          email: 'noname@example.com',
        );

        final userWithFirstNameOnly = UserModel(
          id: 'user790',
          email: 'firstname@example.com',
          firstName: 'Jane',
        );

        final userWithLastNameOnly = UserModel(
          id: 'user791',
          email: 'lastname@example.com',
          lastName: 'Smith',
        );

        // Act & Assert
        expect(userWithoutNames.fullName, equals('User'));
        expect(userWithFirstNameOnly.fullName, equals('Jane'));
        expect(userWithLastNameOnly.fullName, equals('Smith'));
      });

      test('should calculate BMI correctly', () {
        // Act
        final bmi = testUser.bmi;

        // Assert
        // BMI = weight(kg) / height(m)^2
        // BMI = 70 / (1.75)^2 = 70 / 3.0625 ≈ 22.86
        expect(bmi, closeTo(22.86, 0.01));
      });

      test('should handle invalid height/weight for BMI', () {
        // Arrange
        final userWithZeroHeight = testUser.copyWith(height: 0.0);
        final userWithZeroWeight = testUser.copyWith(weight: 0.0);
        final userWithNegativeValues = testUser.copyWith(height: -175.0, weight: -70.0);

        // Act & Assert
        expect(userWithZeroHeight.bmi, equals(0.0));
        expect(userWithZeroWeight.bmi, equals(0.0));
        expect(userWithNegativeValues.bmi, equals(0.0));
      });

      test('should return correct BMI category', () {
        // Test different BMI categories
        final underweightUser = testUser.copyWith(weight: 50.0, height: 175.0); // BMI ≈ 16.3
        final normalUser = testUser.copyWith(weight: 70.0, height: 175.0); // BMI ≈ 22.9
        final overweightUser = testUser.copyWith(weight: 85.0, height: 175.0); // BMI ≈ 27.8
        final obeseUser = testUser.copyWith(weight: 100.0, height: 175.0); // BMI ≈ 32.7
        final unknownUser = testUser.copyWith(weight: 0.0, height: 0.0);

        // Act & Assert
        expect(underweightUser.bmiCategory, equals('Underweight'));
        expect(normalUser.bmiCategory, equals('Normal'));
        expect(overweightUser.bmiCategory, equals('Overweight'));
        expect(obeseUser.bmiCategory, equals('Obese'));
        expect(unknownUser.bmiCategory, equals('Unknown'));
      });

      test('should calculate age correctly', () {
        // Arrange
        final currentYear = DateTime.now().year;
        final birthYear = currentYear - 30;
        final userWith30Years = testUser.copyWith(dateOfBirth: '$birthYear-06-15');

        // Act
        final age = userWith30Years.age;

        // Assert
        expect(age, anyOf([29, 30])); // Depends on current date vs birth date
      });

      test('should handle invalid date of birth for age', () {
        // Arrange
        final userWithInvalidDate = testUser.copyWith(dateOfBirth: 'invalid-date');
        final userWithEmptyDate = testUser.copyWith(dateOfBirth: '');

        // Act & Assert
        expect(userWithInvalidDate.age, equals(0));
        expect(userWithEmptyDate.age, equals(0));
      });

      test('should calculate age considering month and day', () {
        // Arrange
        final now = DateTime.now();
        final birthYear = now.year - 25;
        
        // Birthday hasn't occurred this year
        final futureDate = DateTime(birthYear, now.month + 1, now.day);
        final userFutureBirthday = testUser.copyWith(
          dateOfBirth: '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}'
        );

        // Birthday already occurred this year
        final pastDate = DateTime(birthYear, now.month - 1, now.day);
        final userPastBirthday = testUser.copyWith(
          dateOfBirth: '${pastDate.year}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}'
        );

        // Act
        final ageFuture = userFutureBirthday.age;
        final agePast = userPastBirthday.age;

        // Assert
        expect(ageFuture, equals(24)); // Haven't had birthday yet
        expect(agePast, equals(25)); // Already had birthday
      });
    });

    group('Serialization Tests', () {
      test('should convert to Map correctly', () {
        // Act
        final map = testUser.toMap();

        // Assert
        expect(map['email'], equals('test@example.com'));
        expect(map['firstName'], equals('John'));
        expect(map['lastName'], equals('Doe'));
        expect(map['dateOfBirth'], equals('1990-01-15'));
        expect(map['gender'], equals('Nam'));
        expect(map['phone'], equals('0123456789'));
        expect(map['weight'], equals(70.0));
        expect(map['height'], equals(175.0));
        expect(map['targetWeight'], equals(65.0));
        expect(map['updatedAt'], isNotNull); // FieldValue.serverTimestamp()
        expect(map.containsKey('id'), isFalse); // ID not included in toMap
        expect(map.containsKey('createdAt'), isFalse); // createdAt not included
      });
    });

    group('copyWith Tests', () {
      test('should copy with new values', () {
        // Act
        final updatedUser = testUser.copyWith(
          firstName: 'Jane',
          weight: 65.0,
          targetWeight: 60.0,
        );

        // Assert
        expect(updatedUser.id, equals(testUser.id)); // Unchanged
        expect(updatedUser.email, equals(testUser.email)); // Unchanged
        expect(updatedUser.firstName, equals('Jane')); // Changed
        expect(updatedUser.lastName, equals(testUser.lastName)); // Unchanged
        expect(updatedUser.weight, equals(65.0)); // Changed
        expect(updatedUser.targetWeight, equals(60.0)); // Changed
        expect(updatedUser.height, equals(testUser.height)); // Unchanged
      });

      test('should maintain original values when no changes provided', () {
        // Act
        final copiedUser = testUser.copyWith();

        // Assert
        expect(copiedUser.id, equals(testUser.id));
        expect(copiedUser.email, equals(testUser.email));
        expect(copiedUser.firstName, equals(testUser.firstName));
        expect(copiedUser.lastName, equals(testUser.lastName));
        expect(copiedUser.weight, equals(testUser.weight));
        expect(copiedUser.height, equals(testUser.height));
        expect(copiedUser.targetWeight, equals(testUser.targetWeight));
      });

      test('should handle null values correctly', () {
        // Act
        final updatedUser = testUser.copyWith(
          firstName: null, // Should keep original
          weight: null, // Should keep original
        );

        // Assert
        expect(updatedUser.firstName, equals(testUser.firstName));
        expect(updatedUser.weight, equals(testUser.weight));
      });
    });

    group('Equality and HashCode Tests', () {
      test('should be equal when IDs are the same', () {
        // Arrange
        final user1 = UserModel(id: 'same_id', email: 'user1@example.com');
        final user2 = UserModel(id: 'same_id', email: 'user2@example.com');

        // Act & Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        // Arrange
        final user1 = UserModel(id: 'id1', email: 'same@example.com');
        final user2 = UserModel(id: 'id2', email: 'same@example.com');

        // Act & Assert
        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      test('should be equal to itself', () {
        // Act & Assert
        expect(testUser, equals(testUser));
        expect(testUser.hashCode, equals(testUser.hashCode));
      });
    });

    group('toString Tests', () {
      test('should return correct string representation', () {
        // Act
        final stringRepresentation = testUser.toString();

        // Assert
        expect(stringRepresentation, contains('user123'));
        expect(stringRepresentation, contains('test@example.com'));
        expect(stringRepresentation, contains('John Doe'));
        expect(stringRepresentation, contains('70.0'));
        expect(stringRepresentation, contains('175.0'));
      });
    });

    group('Edge Cases', () {
      test('should handle extreme weight and height values', () {
        // Arrange
        final extremeUser = testUser.copyWith(
          weight: 999.9,
          height: 300.0,
        );

        // Act & Assert
        expect(extremeUser.weight, equals(999.9));
        expect(extremeUser.height, equals(300.0));
        expect(extremeUser.bmi, isA<double>());
        expect(extremeUser.bmi, greaterThan(0));
      });

      test('should handle very old and very young ages', () {
        // Arrange
        final veryOldUser = testUser.copyWith(dateOfBirth: '1900-01-01');
        final veryYoungUser = testUser.copyWith(dateOfBirth: '2020-01-01');

        // Act
        final oldAge = veryOldUser.age;
        final youngAge = veryYoungUser.age;

        // Assert
        expect(oldAge, greaterThan(100));
        expect(youngAge, lessThan(10));
      });

      test('should handle special characters in names', () {
        // Arrange
        final specialUser = testUser.copyWith(
          firstName: 'José',
          lastName: "O'Connor",
        );

        // Act & Assert
        expect(specialUser.fullName, equals("José O'Connor"));
      });
    });
  });
}
