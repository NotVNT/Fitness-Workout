import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness/services/sleep_schedule_service.dart';
import 'package:fitness/models/sleep_schedule.dart';

void main() {
  group('SleepScheduleService Tests', () {
    late SleepSchedule testSchedule;
    late DateTime testDate;

    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      testSchedule = SleepSchedule(
        bedtimeHour: 22,
        bedtimeMinute: 30,
        sleepHours: 8,
        sleepMinutes: 0,
        vibrate: true,
        repeat: 'Everyday',
      );
      
      testDate = DateTime(2024, 1, 15);
    });

    group('save', () {
      test('should save sleep schedule correctly', () async {
        // Act
        await SleepScheduleService.save(testDate, testSchedule);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedValue = prefs.getString('sleep_schedule_2024-01-15');
        expect(savedValue, isNotNull);
        expect(savedValue, contains('"bedtimeHour":22'));
        expect(savedValue, contains('"bedtimeMinute":30'));
        expect(savedValue, contains('"sleepHours":8'));
        expect(savedValue, contains('"vibrate":true'));
      });

      test('should save different schedules for different dates', () async {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        final schedule1 = SleepSchedule(
          bedtimeHour: 22,
          bedtimeMinute: 0,
          sleepHours: 8,
          sleepMinutes: 0,
          vibrate: true,
          repeat: 'Everyday',
        );
        final schedule2 = SleepSchedule(
          bedtimeHour: 23,
          bedtimeMinute: 30,
          sleepHours: 7,
          sleepMinutes: 30,
          vibrate: false,
          repeat: 'Mon-Fri',
        );

        // Act
        await SleepScheduleService.save(date1, schedule1);
        await SleepScheduleService.save(date2, schedule2);

        // Assert
        final loaded1 = await SleepScheduleService.load(date1);
        final loaded2 = await SleepScheduleService.load(date2);

        expect(loaded1!.bedtimeHour, equals(22));
        expect(loaded1.vibrate, isTrue);
        
        expect(loaded2!.bedtimeHour, equals(23));
        expect(loaded2.vibrate, isFalse);
      });

      test('should handle date formatting correctly', () async {
        // Test different date formats
        final dates = [
          DateTime(2024, 1, 1),   // Single digit month and day
          DateTime(2024, 12, 31), // Double digit month and day
          DateTime(2024, 5, 15),  // Mixed
        ];

        for (final date in dates) {
          await SleepScheduleService.save(date, testSchedule);
          final loaded = await SleepScheduleService.load(date);
          expect(loaded, isNotNull);
          expect(loaded!.bedtimeHour, equals(testSchedule.bedtimeHour));
        }
      });
    });

    group('load', () {
      test('should return null when no schedule exists for date', () async {
        // Act
        final result = await SleepScheduleService.load(testDate);

        // Assert
        expect(result, isNull);
      });

      test('should load saved schedule correctly', () async {
        // Arrange
        await SleepScheduleService.save(testDate, testSchedule);

        // Act
        final result = await SleepScheduleService.load(testDate);

        // Assert
        expect(result, isNotNull);
        expect(result!.bedtimeHour, equals(testSchedule.bedtimeHour));
        expect(result.bedtimeMinute, equals(testSchedule.bedtimeMinute));
        expect(result.sleepHours, equals(testSchedule.sleepHours));
        expect(result.sleepMinutes, equals(testSchedule.sleepMinutes));
        expect(result.vibrate, equals(testSchedule.vibrate));
        expect(result.repeat, equals(testSchedule.repeat));
      });

      test('should handle corrupted data gracefully', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sleep_schedule_2024-01-15', 'invalid_json');

        // Act & Assert
        expect(() => SleepScheduleService.load(testDate), throwsA(isA<FormatException>()));
      });

      test('should load schedule with default values for missing fields', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sleep_schedule_2024-01-15', '{"bedtimeHour":20}');

        // Act
        final result = await SleepScheduleService.load(testDate);

        // Assert
        expect(result, isNotNull);
        expect(result!.bedtimeHour, equals(20));
        expect(result.bedtimeMinute, equals(0)); // Default value
        expect(result.sleepHours, equals(8)); // Default value
        expect(result.vibrate, isTrue); // Default value
        expect(result.repeat, equals('Mon-Fri')); // Default value
      });
    });

    group('delete', () {
      test('should delete existing schedule', () async {
        // Arrange
        await SleepScheduleService.save(testDate, testSchedule);
        final beforeDelete = await SleepScheduleService.load(testDate);
        expect(beforeDelete, isNotNull);

        // Act
        await SleepScheduleService.delete(testDate);

        // Assert
        final afterDelete = await SleepScheduleService.load(testDate);
        expect(afterDelete, isNull);
      });

      test('should handle deleting non-existent schedule gracefully', () async {
        // Act & Assert
        expect(() => SleepScheduleService.delete(testDate), returnsNormally);
      });

      test('should only delete specific date schedule', () async {
        // Arrange
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        
        await SleepScheduleService.save(date1, testSchedule);
        await SleepScheduleService.save(date2, testSchedule);

        // Act
        await SleepScheduleService.delete(date1);

        // Assert
        final deleted = await SleepScheduleService.load(date1);
        final remaining = await SleepScheduleService.load(date2);
        
        expect(deleted, isNull);
        expect(remaining, isNotNull);
      });
    });

    group('Integration Tests', () {
      test('should maintain data consistency across operations', () async {
        // Save
        await SleepScheduleService.save(testDate, testSchedule);
        
        // Load and verify
        final loaded = await SleepScheduleService.load(testDate);
        expect(loaded, isNotNull);
        
        // Update
        final updatedSchedule = SleepSchedule(
          bedtimeHour: 21,
          bedtimeMinute: 0,
          sleepHours: 9,
          sleepMinutes: 0,
          vibrate: false,
          repeat: 'Weekends',
        );
        await SleepScheduleService.save(testDate, updatedSchedule);
        
        // Load updated
        final loadedUpdated = await SleepScheduleService.load(testDate);
        expect(loadedUpdated!.bedtimeHour, equals(21));
        expect(loadedUpdated.vibrate, isFalse);
        
        // Delete
        await SleepScheduleService.delete(testDate);
        final afterDelete = await SleepScheduleService.load(testDate);
        expect(afterDelete, isNull);
      });

      test('should handle multiple schedules for different dates', () async {
        // Create schedules for a week
        final schedules = <DateTime, SleepSchedule>{};
        for (int i = 0; i < 7; i++) {
          final date = DateTime(2024, 1, 15 + i);
          final schedule = SleepSchedule(
            bedtimeHour: 22 + (i % 2), // Alternate between 22 and 23
            bedtimeMinute: i * 5,
            sleepHours: 8,
            sleepMinutes: 0,
            vibrate: i % 2 == 0,
            repeat: i < 5 ? 'Mon-Fri' : 'Weekends',
          );
          schedules[date] = schedule;
          await SleepScheduleService.save(date, schedule);
        }

        // Verify all schedules
        for (final entry in schedules.entries) {
          final loaded = await SleepScheduleService.load(entry.key);
          expect(loaded, isNotNull);
          expect(loaded!.bedtimeHour, equals(entry.value.bedtimeHour));
          expect(loaded.bedtimeMinute, equals(entry.value.bedtimeMinute));
          expect(loaded.vibrate, equals(entry.value.vibrate));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle extreme dates', () async {
        final extremeDates = [
          DateTime(1970, 1, 1),
          DateTime(2100, 12, 31),
          DateTime(2024, 2, 29), // Leap year
        ];

        for (final date in extremeDates) {
          await SleepScheduleService.save(date, testSchedule);
          final loaded = await SleepScheduleService.load(date);
          expect(loaded, isNotNull);
          expect(loaded!.bedtimeHour, equals(testSchedule.bedtimeHour));
        }
      });

      test('should handle extreme schedule values', () async {
        final extremeSchedule = SleepSchedule(
          bedtimeHour: 0,
          bedtimeMinute: 0,
          sleepHours: 23,
          sleepMinutes: 59,
          vibrate: false,
          repeat: 'Custom Schedule',
        );

        await SleepScheduleService.save(testDate, extremeSchedule);
        final loaded = await SleepScheduleService.load(testDate);
        
        expect(loaded, isNotNull);
        expect(loaded!.bedtimeHour, equals(0));
        expect(loaded.sleepHours, equals(23));
        expect(loaded.sleepMinutes, equals(59));
      });
    });
  });
}
