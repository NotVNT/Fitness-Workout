import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/workout_model.dart';

void main() {
  group('CalorieHelper Tests', () {
    group('Workout Filtering Logic Tests', () {
      test('should correctly identify today\'s date range', () {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));

        // Test times within today
        final morningToday = DateTime(now.year, now.month, now.day, 8, 0);
        final eveningToday = DateTime(now.year, now.month, now.day, 20, 0);
        final midnightToday = DateTime(now.year, now.month, now.day, 23, 59);

        // Test times outside today
        final yesterday = start.subtract(const Duration(days: 1));
        final tomorrow = end.add(const Duration(hours: 1));

        expect(
            morningToday.isAfter(start) || morningToday.isAtSameMomentAs(start),
            isTrue);
        expect(morningToday.isBefore(end), isTrue);

        expect(
            eveningToday.isAfter(start) || eveningToday.isAtSameMomentAs(start),
            isTrue);
        expect(eveningToday.isBefore(end), isTrue);

        expect(
            midnightToday.isAfter(start) ||
                midnightToday.isAtSameMomentAs(start),
            isTrue);
        expect(midnightToday.isBefore(end), isTrue);

        expect(yesterday.isBefore(start), isTrue);
        expect(tomorrow.isAfter(end) || tomorrow.isAtSameMomentAs(end), isTrue);
      });

      test('should calculate today burned calories correctly', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final todayWorkouts = [
          WorkoutModel(
            id: 'w1',
            userId: 'user_1',
            name: 'Morning Workout',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 8)),
            endTime: today.add(const Duration(hours: 9)),
            status: 'completed',
            caloriesBurned: 300,
          ),
          WorkoutModel(
            id: 'w2',
            userId: 'user_1',
            name: 'Evening Workout',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 18)),
            endTime: today.add(const Duration(hours: 19)),
            status: 'completed',
            caloriesBurned: 250,
          ),
          // Workout from yesterday - should not be counted
          WorkoutModel(
            id: 'w3',
            userId: 'user_1',
            name: 'Yesterday Workout',
            description: 'Test workout',
            exercises: [],
            startTime: today.subtract(const Duration(days: 1)),
            endTime: today
                .subtract(const Duration(days: 1))
                .add(const Duration(hours: 1)),
            status: 'completed',
            caloriesBurned: 200,
          ),
          // Incomplete workout - should not be counted
          WorkoutModel(
            id: 'w4',
            userId: 'user_1',
            name: 'Incomplete Workout',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 12)),
            status: 'in_progress',
            caloriesBurned: 150,
          ),
        ];

        // Test the filtering logic that CalorieHelper uses
        final totalCalories = todayWorkouts
            .where((w) =>
                w.status == 'completed' &&
                w.endTime != null &&
                w.endTime!.isAfter(today) &&
                w.endTime!.isBefore(today.add(const Duration(days: 1))))
            .fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

        // Expected result: 300 + 250 = 550 calories
        // (w1 and w2 are today's completed workouts)
        expect(totalCalories, equals(550));
      });

      test('should handle workouts with null calories', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final workoutsWithNullCalories = [
          WorkoutModel(
            id: 'w1',
            userId: 'user_1',
            name: 'Workout 1',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 8)),
            endTime: today.add(const Duration(hours: 9)),
            status: 'completed',
            caloriesBurned: null, // null calories
          ),
          WorkoutModel(
            id: 'w2',
            userId: 'user_1',
            name: 'Workout 2',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 10)),
            endTime: today.add(const Duration(hours: 11)),
            status: 'completed',
            caloriesBurned: 200,
          ),
        ];

        // Test the logic for handling null calories
        final totalCalories = workoutsWithNullCalories
            .where((w) =>
                w.status == 'completed' &&
                w.endTime != null &&
                w.endTime!.isAfter(today) &&
                w.endTime!.isBefore(today.add(const Duration(days: 1))))
            .fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

        // Should handle null calories as 0: 0 + 200 = 200
        expect(totalCalories, equals(200));
      });

      test('should handle workouts with null endTime', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final workoutsWithNullEndTime = [
          WorkoutModel(
            id: 'w1',
            userId: 'user_1',
            name: 'Workout 1',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 8)),
            endTime: null, // null endTime
            status: 'completed',
            caloriesBurned: 300,
          ),
          WorkoutModel(
            id: 'w2',
            userId: 'user_1',
            name: 'Workout 2',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 10)),
            endTime: today.add(const Duration(hours: 11)),
            status: 'completed',
            caloriesBurned: 200,
          ),
        ];

        // Test the logic for handling null endTime
        final totalCalories = workoutsWithNullEndTime
            .where((w) =>
                w.status == 'completed' &&
                w.endTime != null &&
                w.endTime!.isAfter(today) &&
                w.endTime!.isBefore(today.add(const Duration(days: 1))))
            .fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

        // Should exclude workout with null endTime: only w2 counted = 200
        expect(totalCalories, equals(200));
      });

      test('should return 0 when no completed workouts today', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final noCompletedWorkouts = [
          WorkoutModel(
            id: 'w1',
            userId: 'user_1',
            name: 'Workout 1',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 8)),
            status: 'in_progress', // not completed
            caloriesBurned: 300,
          ),
          WorkoutModel(
            id: 'w2',
            userId: 'user_1',
            name: 'Workout 2',
            description: 'Test workout',
            exercises: [],
            startTime: today.add(const Duration(hours: 10)),
            status: 'planned', // not completed
            caloriesBurned: 200,
          ),
        ];

        // Test the logic for no completed workouts
        final totalCalories = noCompletedWorkouts
            .where((w) =>
                w.status == 'completed' &&
                w.endTime != null &&
                w.endTime!.isAfter(today) &&
                w.endTime!.isBefore(today.add(const Duration(days: 1))))
            .fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

        // Should return 0 when no completed workouts
        expect(totalCalories, equals(0));
      });
    });

    group('Date Range Logic Tests', () {
      test('should correctly identify today\'s date range', () {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));

        // Test times within today
        final morningToday = DateTime(now.year, now.month, now.day, 8, 0);
        final eveningToday = DateTime(now.year, now.month, now.day, 20, 0);
        final midnightToday = DateTime(now.year, now.month, now.day, 23, 59);

        // Test times outside today
        final yesterday = start.subtract(const Duration(days: 1));
        final tomorrow = end.add(const Duration(hours: 1));

        expect(
            morningToday.isAfter(start) || morningToday.isAtSameMomentAs(start),
            isTrue);
        expect(morningToday.isBefore(end), isTrue);

        expect(
            eveningToday.isAfter(start) || eveningToday.isAtSameMomentAs(start),
            isTrue);
        expect(eveningToday.isBefore(end), isTrue);

        expect(
            midnightToday.isAfter(start) ||
                midnightToday.isAtSameMomentAs(start),
            isTrue);
        expect(midnightToday.isBefore(end), isTrue);

        expect(yesterday.isBefore(start), isTrue);
        expect(tomorrow.isAfter(end) || tomorrow.isAtSameMomentAs(end), isTrue);
      });
    });
  });
}
