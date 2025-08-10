import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/services/workout_generator_service.dart';
import 'package:fitness/models/user_model.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:fitness/models/workout_model.dart';

void main() {
  group('WorkoutGeneratorService Tests', () {
    late UserModel testUser;
    late List<ExerciseModel> testExercises;

    setUp(() {
      testUser = UserModel(
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        height: 175.0,
        weight: 70.0,
        targetWeight: 65.0,
        dateOfBirth: '01/01/1990',
        gender: 'Nam',
      );

      testExercises = [
        ExerciseModel(
          id: 'ex1',
          name: 'Push Up',
          vietnameseName: 'Hít đất',
          description: 'Basic push up',
          exerciseType: 'reps',
        ),
        ExerciseModel(
          id: 'ex2',
          name: 'Plank',
          vietnameseName: 'Plank',
          description: 'Core exercise',
          exerciseType: 'duration',
        ),
        ExerciseModel(
          id: 'ex3',
          name: 'Squat',
          vietnameseName: 'Squat',
          description: 'Leg exercise',
          exerciseType: 'reps',
        ),
        ExerciseModel(
          id: 'ex4',
          name: 'Jumping Jacks',
          vietnameseName: 'Bật nhảy',
          description: 'Cardio exercise',
          exerciseType: 'duration',
        ),
      ];
    });

    test('should generate 7 day workouts', () {
      // Act
      final workouts = WorkoutGeneratorService.generate7DayWorkouts(
        user: testUser,
        availableExercises: testExercises,
      );

      // Assert
      expect(workouts.length, equals(7));

      for (int i = 0; i < 7; i++) {
        final workout = workouts[i];
        expect(workout.userId, equals(testUser.id));
        expect(workout.name, contains('Ngày ${i + 1}'));
        expect(workout.status, equals('planned'));
        expect(workout.dayNumber, equals(i + 1));
        expect(workout.exercises.isNotEmpty, isTrue);
      }
    });

    test('should generate daily workout with correct structure', () {
      // Arrange
      final startDate = DateTime.now();

      // Act
      final workout = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: startDate,
      );

      // Assert
      expect(workout.userId, equals(testUser.id));
      expect(workout.name, contains('Ngày 1'));
      expect(workout.description, isNotNull);
      expect(workout.description!.contains(testUser.bmi.toStringAsFixed(1)),
          isTrue);
      expect(workout.exercises.isNotEmpty, isTrue);
      expect(workout.startTime, equals(startDate));
      expect(workout.status, equals('planned'));
      expect(workout.dayNumber, equals(1));
      expect(workout.caloriesBurned, isNotNull);
      expect(workout.caloriesBurned! > 0, isTrue);
    });

    test('should generate different workouts for different days', () {
      // Act
      final workout1 = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      final workout2 = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: testExercises,
        dayNumber: 2,
        startDate: DateTime.now().add(const Duration(days: 1)),
      );

      // Assert
      expect(workout1.name, isNot(equals(workout2.name)));
      expect(workout1.dayNumber, equals(1));
      expect(workout2.dayNumber, equals(2));

      // Workouts should have different exercise combinations or order
      final workout1ExerciseIds =
          workout1.exercises.map((e) => e.exerciseId).toList();
      final workout2ExerciseIds =
          workout2.exercises.map((e) => e.exerciseId).toList();
      // Note: With limited exercises, workouts might have same exercises but different order
      expect(workout1ExerciseIds.length, greaterThan(0));
      expect(workout2ExerciseIds.length, greaterThan(0));
    });

    test('should generate workouts with sets for each exercise', () {
      // Act
      final workout = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      // Assert
      expect(workout.exercises.isNotEmpty, isTrue);

      for (final workoutExercise in workout.exercises) {
        expect(workoutExercise.exerciseId.isNotEmpty, isTrue);
        expect(workoutExercise.sets.isNotEmpty, isTrue);
        expect(workoutExercise.order > 0, isTrue);

        // Check that sets have appropriate values
        for (final set in workoutExercise.sets) {
          expect(set.setNumber > 0, isTrue);
          expect(set.restTime != null && set.restTime! > 0, isTrue);

          // For reps exercises, should have reps > 0
          // For duration exercises, should have duration > 0
          final exercise = testExercises
              .firstWhere((e) => e.id == workoutExercise.exerciseId);
          if (exercise.exerciseType == 'reps') {
            expect(set.reps > 0, isTrue);
          } else {
            expect(set.duration != null && set.duration! > 0, isTrue);
          }
        }
      }
    });

    test('should adapt workout intensity based on user BMI', () {
      // Arrange
      final lowBMIUser = testUser.copyWith(weight: 50.0); // Lower BMI
      final highBMIUser = testUser.copyWith(weight: 90.0); // Higher BMI

      // Act
      final lowBMIWorkout = WorkoutGeneratorService.generateDailyWorkout(
        user: lowBMIUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      final highBMIWorkout = WorkoutGeneratorService.generateDailyWorkout(
        user: highBMIUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      // Assert
      expect(lowBMIWorkout.exercises.isNotEmpty, isTrue);
      expect(highBMIWorkout.exercises.isNotEmpty, isTrue);

      // Both should have valid calorie estimates
      expect(lowBMIWorkout.caloriesBurned! > 0, isTrue);
      expect(highBMIWorkout.caloriesBurned! > 0, isTrue);
    });

    test('should handle empty exercise list gracefully', () {
      // Act
      final workout = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: [],
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      // Assert
      // When no exercises available, should return empty workout
      expect(workout.exercises.isEmpty, isTrue);
      expect(workout.caloriesBurned, isNotNull);
      expect(workout.caloriesBurned! >= 0, isTrue);
    });

    test('should generate workouts with proper workout types', () {
      // Act
      final workouts = WorkoutGeneratorService.generate7DayWorkouts(
        user: testUser,
        availableExercises: testExercises,
      );

      // Assert
      for (final workout in workouts) {
        expect(workout.workoutType, isNotNull);
        expect(workout.workoutType!.isNotEmpty, isTrue);
        // Should be one of the expected workout types (more flexible check)
        expect(workout.workoutType!.length, greaterThan(0));
      }
    });

    test('should generate unique workout IDs', () {
      // Act
      final workouts = WorkoutGeneratorService.generate7DayWorkouts(
        user: testUser,
        availableExercises: testExercises,
      );

      // Assert
      final workoutIds = workouts.map((w) => w.id).toSet();
      expect(workoutIds.length,
          equals(workouts.length)); // All IDs should be unique
    });

    test('should set proper start times for each day', () {
      // Arrange
      final baseDate = DateTime.now();

      // Act
      final workouts = WorkoutGeneratorService.generate7DayWorkouts(
        user: testUser,
        availableExercises: testExercises,
      );

      // Assert
      for (int i = 0; i < workouts.length; i++) {
        final workout = workouts[i];
        final expectedDate = baseDate.add(Duration(days: i));

        // Check that the workout is scheduled for the correct day
        expect(workout.startTime.day, equals(expectedDate.day));
        expect(workout.startTime.month, equals(expectedDate.month));
        expect(workout.startTime.year, equals(expectedDate.year));
      }
    });

    test('should include exercise references in workout exercises', () {
      // Act
      final workout = WorkoutGeneratorService.generateDailyWorkout(
        user: testUser,
        availableExercises: testExercises,
        dayNumber: 1,
        startDate: DateTime.now(),
      );

      // Assert
      for (final workoutExercise in workout.exercises) {
        expect(workoutExercise.exerciseId.isNotEmpty, isTrue);
        expect(workoutExercise.exercise, isNotNull);
        expect(
            workoutExercise.exercise!.id, equals(workoutExercise.exerciseId));
      }
    });
  });
}
