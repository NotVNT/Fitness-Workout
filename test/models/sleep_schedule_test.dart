import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/sleep_schedule.dart';

void main() {
  group('SleepSchedule Tests', () {
    late SleepSchedule testSchedule;

    setUp(() {
      testSchedule = SleepSchedule(
        bedtimeHour: 22,
        bedtimeMinute: 30,
        sleepHours: 8,
        sleepMinutes: 0,
        vibrate: true,
        repeat: 'Everyday',
      );
    });

    group('Constructor Tests', () {
      test('should create SleepSchedule with all required fields', () {
        // Act & Assert
        expect(testSchedule.bedtimeHour, equals(22));
        expect(testSchedule.bedtimeMinute, equals(30));
        expect(testSchedule.sleepHours, equals(8));
        expect(testSchedule.sleepMinutes, equals(0));
        expect(testSchedule.vibrate, isTrue);
        expect(testSchedule.repeat, equals('Everyday'));
      });

      test('should create SleepSchedule with edge time values', () {
        // Arrange & Act
        final midnightSchedule = SleepSchedule(
          bedtimeHour: 0,
          bedtimeMinute: 0,
          sleepHours: 8,
          sleepMinutes: 30,
          vibrate: false,
          repeat: 'Mon-Fri',
        );

        final lateSchedule = SleepSchedule(
          bedtimeHour: 23,
          bedtimeMinute: 59,
          sleepHours: 6,
          sleepMinutes: 1,
          vibrate: true,
          repeat: 'Weekends',
        );

        // Assert
        expect(midnightSchedule.bedtimeHour, equals(0));
        expect(midnightSchedule.bedtimeMinute, equals(0));
        
        expect(lateSchedule.bedtimeHour, equals(23));
        expect(lateSchedule.bedtimeMinute, equals(59));
      });
    });

    group('bedtimeOn Tests', () {
      test('should return correct bedtime for given date', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15, 10, 0); // 10:00 AM

        // Act
        final bedtime = testSchedule.bedtimeOn(testDate);

        // Assert
        expect(bedtime.year, equals(2024));
        expect(bedtime.month, equals(1));
        expect(bedtime.day, equals(15));
        expect(bedtime.hour, equals(22));
        expect(bedtime.minute, equals(30));
        expect(bedtime.second, equals(0));
      });

      test('should handle different dates correctly', () {
        // Arrange
        final dates = [
          DateTime(2024, 1, 1),
          DateTime(2024, 6, 15),
          DateTime(2024, 12, 31),
        ];

        // Act & Assert
        for (final date in dates) {
          final bedtime = testSchedule.bedtimeOn(date);
          expect(bedtime.year, equals(date.year));
          expect(bedtime.month, equals(date.month));
          expect(bedtime.day, equals(date.day));
          expect(bedtime.hour, equals(22));
          expect(bedtime.minute, equals(30));
        }
      });

      test('should handle midnight bedtime', () {
        // Arrange
        final midnightSchedule = SleepSchedule(
          bedtimeHour: 0,
          bedtimeMinute: 0,
          sleepHours: 8,
          sleepMinutes: 0,
          vibrate: true,
          repeat: 'Everyday',
        );
        final testDate = DateTime(2024, 1, 15);

        // Act
        final bedtime = midnightSchedule.bedtimeOn(testDate);

        // Assert
        expect(bedtime.hour, equals(0));
        expect(bedtime.minute, equals(0));
      });
    });

    group('wakeTimeOn Tests', () {
      test('should return correct wake time for given date', () {
        // Arrange
        final testDate = DateTime(2024, 1, 15);

        // Act
        final wakeTime = testSchedule.wakeTimeOn(testDate);

        // Assert
        expect(wakeTime.year, equals(2024));
        expect(wakeTime.month, equals(1));
        expect(wakeTime.day, equals(16)); // Next day
        expect(wakeTime.hour, equals(6)); // 22:30 + 8:00 = 6:30 next day
        expect(wakeTime.minute, equals(30));
      });

      test('should handle wake time crossing midnight', () {
        // Arrange
        final lateSchedule = SleepSchedule(
          bedtimeHour: 23,
          bedtimeMinute: 30,
          sleepHours: 8,
          sleepMinutes: 0,
          vibrate: true,
          repeat: 'Everyday',
        );
        final testDate = DateTime(2024, 1, 15);

        // Act
        final wakeTime = lateSchedule.wakeTimeOn(testDate);

        // Assert
        expect(wakeTime.year, equals(2024));
        expect(wakeTime.month, equals(1));
        expect(wakeTime.day, equals(16)); // Next day
        expect(wakeTime.hour, equals(7)); // 23:30 + 8:00 = 7:30 next day
        expect(wakeTime.minute, equals(30));
      });

      test('should handle short sleep duration', () {
        // Arrange
        final shortSchedule = SleepSchedule(
          bedtimeHour: 23,
          bedtimeMinute: 0,
          sleepHours: 4,
          sleepMinutes: 30,
          vibrate: true,
          repeat: 'Everyday',
        );
        final testDate = DateTime(2024, 1, 15);

        // Act
        final wakeTime = shortSchedule.wakeTimeOn(testDate);

        // Assert
        expect(wakeTime.day, equals(16)); // Next day
        expect(wakeTime.hour, equals(3)); // 23:00 + 4:30 = 3:30 next day
        expect(wakeTime.minute, equals(30));
      });

      test('should handle wake time within same day', () {
        // Arrange
        final earlySchedule = SleepSchedule(
          bedtimeHour: 20,
          bedtimeMinute: 0,
          sleepHours: 3,
          sleepMinutes: 0,
          vibrate: true,
          repeat: 'Everyday',
        );
        final testDate = DateTime(2024, 1, 15);

        // Act
        final wakeTime = earlySchedule.wakeTimeOn(testDate);

        // Assert
        expect(wakeTime.day, equals(15)); // Same day
        expect(wakeTime.hour, equals(23)); // 20:00 + 3:00 = 23:00 same day
        expect(wakeTime.minute, equals(0));
      });

      test('should handle complex sleep duration with minutes', () {
        // Arrange
        final complexSchedule = SleepSchedule(
          bedtimeHour: 21,
          bedtimeMinute: 45,
          sleepHours: 7,
          sleepMinutes: 45,
          vibrate: true,
          repeat: 'Everyday',
        );
        final testDate = DateTime(2024, 1, 15);

        // Act
        final wakeTime = complexSchedule.wakeTimeOn(testDate);

        // Assert
        expect(wakeTime.day, equals(16)); // Next day
        expect(wakeTime.hour, equals(5)); // 21:45 + 7:45 = 5:30 next day
        expect(wakeTime.minute, equals(30));
      });
    });

    group('Serialization Tests', () {
      test('should convert to Map correctly', () {
        // Act
        final map = testSchedule.toMap();

        // Assert
        expect(map['bedtimeHour'], equals(22));
        expect(map['bedtimeMinute'], equals(30));
        expect(map['sleepHours'], equals(8));
        expect(map['sleepMinutes'], equals(0));
        expect(map['vibrate'], isTrue);
        expect(map['repeat'], equals('Everyday'));
      });

      test('should create from Map correctly', () {
        // Arrange
        final map = {
          'bedtimeHour': 21,
          'bedtimeMinute': 15,
          'sleepHours': 9,
          'sleepMinutes': 30,
          'vibrate': false,
          'repeat': 'Mon-Fri',
        };

        // Act
        final schedule = SleepSchedule.fromMap(map);

        // Assert
        expect(schedule.bedtimeHour, equals(21));
        expect(schedule.bedtimeMinute, equals(15));
        expect(schedule.sleepHours, equals(9));
        expect(schedule.sleepMinutes, equals(30));
        expect(schedule.vibrate, isFalse);
        expect(schedule.repeat, equals('Mon-Fri'));
      });

      test('should use default values for missing fields in fromMap', () {
        // Arrange
        final incompleteMap = {
          'bedtimeHour': 20,
          // Missing other fields
        };

        // Act
        final schedule = SleepSchedule.fromMap(incompleteMap);

        // Assert
        expect(schedule.bedtimeHour, equals(20));
        expect(schedule.bedtimeMinute, equals(0)); // Default
        expect(schedule.sleepHours, equals(8)); // Default
        expect(schedule.sleepMinutes, equals(30)); // Default
        expect(schedule.vibrate, isTrue); // Default
        expect(schedule.repeat, equals('Mon-Fri')); // Default
      });

      test('should convert to JSON string correctly', () {
        // Act
        final jsonString = testSchedule.toJson();

        // Assert
        expect(jsonString, isA<String>());
        expect(jsonString, contains('"bedtimeHour":22'));
        expect(jsonString, contains('"bedtimeMinute":30'));
        expect(jsonString, contains('"sleepHours":8'));
        expect(jsonString, contains('"vibrate":true'));
        expect(jsonString, contains('"repeat":"Everyday"'));
      });

      test('should create from JSON string correctly', () {
        // Arrange
        const jsonString = '{"bedtimeHour":23,"bedtimeMinute":45,"sleepHours":7,"sleepMinutes":15,"vibrate":false,"repeat":"Weekends"}';

        // Act
        final schedule = SleepSchedule.fromJson(jsonString);

        // Assert
        expect(schedule.bedtimeHour, equals(23));
        expect(schedule.bedtimeMinute, equals(45));
        expect(schedule.sleepHours, equals(7));
        expect(schedule.sleepMinutes, equals(15));
        expect(schedule.vibrate, isFalse);
        expect(schedule.repeat, equals('Weekends'));
      });

      test('should maintain data integrity through serialization cycle', () {
        // Act
        final jsonString = testSchedule.toJson();
        final recreated = SleepSchedule.fromJson(jsonString);

        // Assert
        expect(recreated.bedtimeHour, equals(testSchedule.bedtimeHour));
        expect(recreated.bedtimeMinute, equals(testSchedule.bedtimeMinute));
        expect(recreated.sleepHours, equals(testSchedule.sleepHours));
        expect(recreated.sleepMinutes, equals(testSchedule.sleepMinutes));
        expect(recreated.vibrate, equals(testSchedule.vibrate));
        expect(recreated.repeat, equals(testSchedule.repeat));
      });
    });

    group('Edge Cases', () {
      test('should handle extreme time values', () {
        // Arrange & Act
        final extremeSchedule = SleepSchedule(
          bedtimeHour: 0,
          bedtimeMinute: 0,
          sleepHours: 23,
          sleepMinutes: 59,
          vibrate: false,
          repeat: 'Custom',
        );

        // Assert
        expect(extremeSchedule.bedtimeHour, equals(0));
        expect(extremeSchedule.sleepHours, equals(23));
        expect(extremeSchedule.sleepMinutes, equals(59));
      });

      test('should handle different repeat patterns', () {
        // Arrange
        final repeatPatterns = [
          'Everyday',
          'Mon-Fri',
          'Weekends',
          'Custom',
          'Never',
        ];

        // Act & Assert
        for (final pattern in repeatPatterns) {
          final schedule = SleepSchedule(
            bedtimeHour: 22,
            bedtimeMinute: 0,
            sleepHours: 8,
            sleepMinutes: 0,
            vibrate: true,
            repeat: pattern,
          );
          expect(schedule.repeat, equals(pattern));
        }
      });
    });
  });
}
