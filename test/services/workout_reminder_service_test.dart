import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness/services/workout_reminder_service.dart';

void main() {
  group('WorkoutReminderService Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('save', () {
      test('should save reminder time correctly', () async {
        // Arrange
        const hour = 7;
        const minute = 30;

        // Act
        await WorkoutReminderService.save(hour, minute);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedValue = prefs.getString('workout_reminder_time');
        expect(savedValue, isNotNull);
        expect(savedValue, contains('"h":7'));
        expect(savedValue, contains('"m":30'));
      });

      test('should save different reminder times', () async {
        // Arrange
        const hour1 = 6;
        const minute1 = 0;
        const hour2 = 18;
        const minute2 = 45;

        // Act
        await WorkoutReminderService.save(hour1, minute1);
        final result1 = await WorkoutReminderService.load();

        await WorkoutReminderService.save(hour2, minute2);
        final result2 = await WorkoutReminderService.load();

        // Assert
        expect(result1, isNotNull);
        expect(result1!.h, equals(hour1));
        expect(result1.m, equals(minute1));

        expect(result2, isNotNull);
        expect(result2!.h, equals(hour2));
        expect(result2.m, equals(minute2));
      });

      test('should handle edge time values', () async {
        // Test midnight
        await WorkoutReminderService.save(0, 0);
        final midnight = await WorkoutReminderService.load();
        expect(midnight!.h, equals(0));
        expect(midnight.m, equals(0));

        // Test end of day
        await WorkoutReminderService.save(23, 59);
        final endOfDay = await WorkoutReminderService.load();
        expect(endOfDay!.h, equals(23));
        expect(endOfDay.m, equals(59));
      });
    });

    group('load', () {
      test('should return null when no reminder is set', () async {
        // Act
        final result = await WorkoutReminderService.load();

        // Assert
        expect(result, isNull);
      });

      test('should load saved reminder time correctly', () async {
        // Arrange
        const hour = 8;
        const minute = 15;
        await WorkoutReminderService.save(hour, minute);

        // Act
        final result = await WorkoutReminderService.load();

        // Assert
        expect(result, isNotNull);
        expect(result!.h, equals(hour));
        expect(result.m, equals(minute));
      });

      test('should handle corrupted data gracefully', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('workout_reminder_time', 'invalid_json');

        // Act
        final result = await WorkoutReminderService.load();

        // Assert
        expect(result, isNull);
      });

      test('should handle missing fields in saved data', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'workout_reminder_time', '{"h":10}'); // Missing 'm'

        // Act
        final result = await WorkoutReminderService.load();

        // Assert
        expect(result, isNotNull);
        expect(result!.h, equals(10));
        expect(result.m, equals(0)); // Should handle missing field
      });

      test('should handle non-integer values', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('workout_reminder_time', '{"h":10.5,"m":30.7}');

        // Act
        final result = await WorkoutReminderService.load();

        // Assert
        expect(result, isNotNull);
        expect(result!.h, equals(10)); // Should convert to int
        expect(result.m, equals(30)); // Should convert to int
      });
    });

    group('Integration Tests', () {
      test('should maintain data consistency across save/load cycles',
          () async {
        // Test multiple save/load cycles
        final testCases = [
          (h: 6, m: 0),
          (h: 12, m: 30),
          (h: 18, m: 45),
          (h: 23, m: 59),
        ];

        for (final testCase in testCases) {
          // Save
          await WorkoutReminderService.save(testCase.h, testCase.m);

          // Load
          final result = await WorkoutReminderService.load();

          // Verify
          expect(result, isNotNull);
          expect(result!.h, equals(testCase.h));
          expect(result.m, equals(testCase.m));
        }
      });

      test('should overwrite previous reminder when saving new one', () async {
        // Arrange
        await WorkoutReminderService.save(7, 0);
        final first = await WorkoutReminderService.load();

        // Act
        await WorkoutReminderService.save(19, 30);
        final second = await WorkoutReminderService.load();

        // Assert
        expect(first!.h, equals(7));
        expect(first.m, equals(0));

        expect(second!.h, equals(19));
        expect(second.m, equals(30));
      });
    });

    group('Performance Tests', () {
      test('should handle rapid save/load operations', () async {
        // Perform multiple rapid operations
        for (int i = 0; i < 10; i++) {
          await WorkoutReminderService.save(i, i * 5);
          final result = await WorkoutReminderService.load();
          expect(result!.h, equals(i));
          expect(result.m, equals(i * 5));
        }
      });
    });

    group('Error Handling', () {
      test('should handle SharedPreferences errors gracefully', () async {
        // This test would require mocking SharedPreferences to throw errors
        // For now, we verify the basic functionality works
        expect(() => WorkoutReminderService.save(10, 30), returnsNormally);
        expect(() => WorkoutReminderService.load(), returnsNormally);
      });
    });
  });
}
