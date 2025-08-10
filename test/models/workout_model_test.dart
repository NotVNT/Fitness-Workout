import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/workout_model.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:fitness/models/set_model.dart';

void main() {
  group('WorkoutExercise Tests', () {
    test('should create WorkoutExercise with required fields', () {
      // Arrange
      final exercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up',
        exerciseType: 'reps',
      );

      final sets = [
        SetModel(
          id: 'set1',
          setNumber: 1,
          reps: 10,
          weight: 0.0,
        ),
      ];

      // Act
      final workoutExercise = WorkoutExercise(
        exerciseId: 'ex1',
        exercise: exercise,
        sets: sets,
        order: 1,
      );

      // Assert
      expect(workoutExercise.exerciseId, equals('ex1'));
      expect(workoutExercise.exercise, equals(exercise));
      expect(workoutExercise.sets, equals(sets));
      expect(workoutExercise.order, equals(1));
      expect(workoutExercise.notes, isNull);
    });

    test('should create WorkoutExercise from Map', () {
      // Arrange
      final data = {
        'exerciseId': 'ex1',
        'sets': [
          {
            'setNumber': 1,
            'reps': 10,
            'weight': 0.0,
            'isCompleted': false,
          }
        ],
        'notes': 'Test notes',
        'order': 1,
      };

      // Act
      final workoutExercise = WorkoutExercise.fromMap(data);

      // Assert
      expect(workoutExercise.exerciseId, equals('ex1'));
      expect(workoutExercise.sets.length, equals(1));
      expect(workoutExercise.sets.first.reps, equals(10));
      expect(workoutExercise.notes, equals('Test notes'));
      expect(workoutExercise.order, equals(1));
    });

    test('should convert WorkoutExercise to Map', () {
      // Arrange
      final sets = [
        SetModel(
          id: 'set1',
          setNumber: 1,
          reps: 10,
          weight: 0.0,
        ),
      ];

      final workoutExercise = WorkoutExercise(
        exerciseId: 'ex1',
        sets: sets,
        notes: 'Test notes',
        order: 1,
      );

      // Act
      final map = workoutExercise.toMap();

      // Assert
      expect(map['exerciseId'], equals('ex1'));
      expect(map['sets'], isA<List>());
      expect(map['notes'], equals('Test notes'));
      expect(map['order'], equals(1));
    });
  });

  group('WorkoutModel Tests', () {
    test('should create WorkoutModel with required fields', () {
      // Arrange
      final startTime = DateTime.now();
      final exercises = <WorkoutExercise>[];

      // Act
      final workout = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Test Workout',
        exercises: exercises,
        startTime: startTime,
        status: 'planned',
      );

      // Assert
      expect(workout.id, equals('w1'));
      expect(workout.userId, equals('u1'));
      expect(workout.name, equals('Test Workout'));
      expect(workout.exercises, equals(exercises));
      expect(workout.startTime, equals(startTime));
      expect(workout.status, equals('planned'));
    });

    test('should create WorkoutModel with all properties', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 30));

      // Act
      final workout = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Test Workout',
        description: 'Test description',
        exercises: [],
        startTime: startTime,
        endTime: endTime,
        status: 'planned',
        workoutType: 'strength',
        caloriesBurned: 100,
        dayNumber: 1,
      );

      // Assert
      expect(workout.id, equals('w1'));
      expect(workout.userId, equals('u1'));
      expect(workout.name, equals('Test Workout'));
      expect(workout.description, equals('Test description'));
      expect(workout.status, equals('planned'));
      expect(workout.workoutType, equals('strength'));
      expect(workout.caloriesBurned, equals(100));
      expect(workout.dayNumber, equals(1));
      expect(workout.endTime, equals(endTime));
    });

    test('should convert WorkoutModel to Map', () {
      // Arrange
      final startTime = DateTime.now();
      final workout = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Test Workout',
        description: 'Test description',
        exercises: [],
        startTime: startTime,
        status: 'planned',
        workoutType: 'strength',
        caloriesBurned: 100,
        dayNumber: 1,
      );

      // Act
      final map = workout.toMap();

      // Assert
      expect(map['userId'], equals('u1'));
      expect(map['name'], equals('Test Workout'));
      expect(map['description'], equals('Test description'));
      expect(map['status'], equals('planned'));
      expect(map['workoutType'], equals('strength'));
      expect(map['caloriesBurned'], equals(100));
      expect(map['dayNumber'], equals(1));
    });

    test('should copy WorkoutModel with new values', () {
      // Arrange
      final original = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Original Workout',
        exercises: [],
        startTime: DateTime.now(),
        status: 'planned',
      );

      // Act
      final copied = original.copyWith(
        name: 'Updated Workout',
        status: 'completed',
      );

      // Assert
      expect(copied.id, equals(original.id));
      expect(copied.userId, equals(original.userId));
      expect(copied.name, equals('Updated Workout'));
      expect(copied.status, equals('completed'));
      expect(copied.startTime, equals(original.startTime));
    });

    test('should store duration when provided', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 30));

      final workout = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Test Workout',
        exercises: [],
        startTime: startTime,
        endTime: endTime,
        duration: 30, // Explicitly set duration
        status: 'completed',
      );

      // Act
      final duration = workout.duration;

      // Assert
      expect(duration, equals(30));
    });

    test('should handle null duration', () {
      // Arrange
      final workout = WorkoutModel(
        id: 'w1',
        userId: 'u1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        status: 'planned',
        // duration not provided, should be null
      );

      // Act
      final duration = workout.duration;

      // Assert
      expect(duration, isNull);
    });
  });
}
