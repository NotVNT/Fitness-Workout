import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/services/exercise_service.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../test_helpers/firebase_test_setup.dart';

void main() {
  group('ExerciseService Tests', () {
    late ExerciseService exerciseService;
    late FakeFirebaseFirestore fakeFirestore;

    setUpAll(() async {
      await FirebaseTestSetup.setupFirebase();
    });

    setUp(() {
      exerciseService = ExerciseService();
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('getAllExercises', () {
      test('should return cached exercises when cache is not empty', () async {
        // Arrange
        await exerciseService.getAllExercises(); // Load cache first

        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        expect(exercises, isNotNull);
        expect(exercises.isNotEmpty, isTrue);

        // Verify exercises have required fields
        for (final exercise in exercises) {
          expect(exercise.id.isNotEmpty, isTrue);
          expect(exercise.name.isNotEmpty, isTrue);
          expect(exercise.vietnameseName.isNotEmpty, isTrue);
          expect(exercise.exerciseType.isNotEmpty, isTrue);
        }
      });

      test('should force reload exercises from Firestore when requested',
          () async {
        // Arrange
        await _setupExercisesInFirestore(fakeFirestore);

        // Act
        final exercises =
            await exerciseService.getAllExercises(forceReload: true);

        // Assert
        expect(exercises, isNotNull);
        expect(exercises.isNotEmpty, isTrue);
      });

      test('should return default exercises when Firestore is empty', () async {
        // Arrange - Empty Firestore

        // Act
        final exercises =
            await exerciseService.getAllExercises(forceReload: true);

        // Assert
        expect(exercises, isNotNull);
        expect(exercises.isNotEmpty,
            isTrue); // Should fallback to default exercises

        // Verify default exercises structure
        for (final exercise in exercises) {
          expect(exercise.id.isNotEmpty, isTrue);
          expect(exercise.name.isNotEmpty, isTrue);
          expect(exercise.vietnameseName.isNotEmpty, isTrue);
          expect(['reps', 'duration'].contains(exercise.exerciseType), isTrue);
        }
      });

      test('should handle Firestore errors gracefully', () async {
        // Act
        final exercises =
            await exerciseService.getAllExercises(forceReload: true);

        // Assert
        expect(exercises, isNotNull);
        expect(exercises.isNotEmpty,
            isTrue); // Should fallback to default exercises
      });
    });

    group('getExerciseById', () {
      test('should return exercise when ID exists', () async {
        // Arrange
        await exerciseService.getAllExercises(); // Load exercises first
        const exerciseId = 'push_ups'; // Use actual ID from service

        // Act
        final exercise = exerciseService.getExerciseById(exerciseId);

        // Assert
        expect(exercise, isNotNull);
        expect(exercise!.id, equals(exerciseId));
        expect(exercise.name.isNotEmpty, isTrue);
        expect(exercise.vietnameseName.isNotEmpty, isTrue);
      });

      test('should return null when ID does not exist', () {
        // Arrange
        const nonExistentId = 'non_existent_exercise';

        // Act
        final exercise = exerciseService.getExerciseById(nonExistentId);

        // Assert
        expect(exercise, isNull);
      });

      test('should return exercise with correct properties', () async {
        // Arrange
        await exerciseService.getAllExercises(); // Load exercises first
        const exerciseId = 'push_ups'; // Use actual ID from service

        // Act
        final exercise = exerciseService.getExerciseById(exerciseId);

        // Assert
        expect(exercise, isNotNull);
        expect(exercise!.id, equals(exerciseId));
        expect(exercise.name, equals('Push Ups'));
        expect(exercise.vietnameseName, equals('Hít đất'));
        expect(exercise.exerciseType, equals('reps'));
        expect(exercise.description.isNotEmpty, isTrue);
      });
    });

    group('getExercisesByType', () {
      test('should return exercises filtered by reps type', () async {
        // Act
        final repsExercises = await exerciseService.getExercisesByType('reps');

        // Assert
        expect(repsExercises, isNotNull);
        expect(repsExercises.isNotEmpty, isTrue);

        for (final exercise in repsExercises) {
          expect(exercise.exerciseType, equals('reps'));
        }
      });

      test('should return exercises filtered by duration type', () async {
        // Act
        final durationExercises =
            await exerciseService.getExercisesByType('duration');

        // Assert
        expect(durationExercises, isNotNull);
        expect(durationExercises.isNotEmpty, isTrue);

        for (final exercise in durationExercises) {
          expect(exercise.exerciseType, equals('duration'));
        }
      });

      test('should return empty list for non-existent type', () async {
        // Act
        final exercises =
            await exerciseService.getExercisesByType('non_existent_type');

        // Assert
        expect(exercises, isNotNull);
        expect(exercises.isEmpty, isTrue);
      });

      test('should include delay simulation', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await exerciseService.getExercisesByType('reps');

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(300));
      });
    });

    group('Default Exercises', () {
      test('should have predefined exercises with correct structure', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        expect(exercises.isNotEmpty, isTrue);

        // Check for some expected default exercises
        final exerciseIds = exercises.map((e) => e.id).toList();
        expect(exerciseIds.contains('push_ups'), isTrue);
        expect(exerciseIds.contains('squats'), isTrue);
        expect(exerciseIds.contains('plank'), isTrue);

        // Verify exercise types are valid
        for (final exercise in exercises) {
          expect(['reps', 'duration'].contains(exercise.exerciseType), isTrue);
        }
      });

      test('should have both reps and duration exercises', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        final repsExercises =
            exercises.where((e) => e.exerciseType == 'reps').toList();
        final durationExercises =
            exercises.where((e) => e.exerciseType == 'duration').toList();

        expect(repsExercises.isNotEmpty, isTrue);
        expect(durationExercises.isNotEmpty, isTrue);
      });

      test('should have Vietnamese names for all exercises', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        for (final exercise in exercises) {
          expect(exercise.vietnameseName.isNotEmpty, isTrue);
          // Note: Some exercises might have same Vietnamese and English names
          // This is acceptable for exercises like "Burpees"
        }
      });

      test('should have descriptions for all exercises', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        for (final exercise in exercises) {
          expect(exercise.description.isNotEmpty, isTrue);
        }
      });

      test('should have unique IDs for all exercises', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        final exerciseIds = exercises.map((e) => e.id).toList();
        final uniqueIds = exerciseIds.toSet();
        expect(uniqueIds.length, equals(exerciseIds.length));
      });
    });

    group('Cache Management', () {
      test('should use cache on subsequent calls', () async {
        // Arrange
        await exerciseService.getAllExercises(); // First call to populate cache

        // Act
        final stopwatch = Stopwatch()..start();
        final exercises = await exerciseService
            .getAllExercises(); // Second call should use cache
        stopwatch.stop();

        // Assert
        expect(exercises.isNotEmpty, isTrue);
        expect(stopwatch.elapsedMilliseconds,
            lessThan(100)); // Should be fast due to cache
      });

      test('should bypass cache when forceReload is true', () async {
        // Arrange
        await exerciseService.getAllExercises(); // Populate cache

        // Act
        final exercises =
            await exerciseService.getAllExercises(forceReload: true);

        // Assert
        expect(exercises.isNotEmpty, isTrue);
      });
    });

    group('Exercise Properties Validation', () {
      test('should validate exercise model properties', () async {
        // Act
        final exercises = await exerciseService.getAllExercises();

        // Assert
        for (final exercise in exercises) {
          // ID should not be empty
          expect(exercise.id.trim().isNotEmpty, isTrue);

          // Name should not be empty
          expect(exercise.name.trim().isNotEmpty, isTrue);

          // Vietnamese name should not be empty
          expect(exercise.vietnameseName.trim().isNotEmpty, isTrue);

          // Exercise type should be valid
          expect(['reps', 'duration'].contains(exercise.exerciseType), isTrue);

          // Description should not be empty
          expect(exercise.description.trim().isNotEmpty, isTrue);
        }
      });
    });
  });
}

// Helper function to setup exercises in Firestore
Future<void> _setupExercisesInFirestore(FakeFirebaseFirestore firestore) async {
  final exercises = [
    {
      'id': 'ex1',
      'name': 'Push Up',
      'vietnameseName': 'Hít đất',
      'description': 'Basic push up exercise',
      'exerciseType': 'reps',
    },
    {
      'id': 'ex2',
      'name': 'Plank',
      'vietnameseName': 'Plank',
      'description': 'Core strengthening exercise',
      'exerciseType': 'duration',
    },
    {
      'id': 'ex3',
      'name': 'Squat',
      'vietnameseName': 'Squat',
      'description': 'Leg strengthening exercise',
      'exerciseType': 'reps',
    },
  ];

  for (final exercise in exercises) {
    await firestore
        .collection('exercises')
        .doc(exercise['id'] as String)
        .set(exercise);
  }
}
