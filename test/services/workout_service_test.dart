import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/services/workout_service.dart';
import 'package:fitness/models/user_model.dart';
import '../test_helpers/firebase_test_setup.dart';

void main() {
  group('WorkoutService Tests', () {
    late UserModel testUser;

    setUpAll(() async {
      await FirebaseTestSetup.setupFirebase();
    });

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
    });

    group('Firebase Dependency Tests', () {
      test('create7DayWorkoutsForUser should handle Firebase not initialized',
          () async {
        // Arrange - Firebase not initialized in test environment

        // Act
        final workouts =
            await WorkoutService.create7DayWorkoutsForUser(testUser);

        // Assert - Should return null due to Firebase error
        expect(workouts, isNull);
      });

      test('createAutoWorkoutForUser should handle Firebase not initialized',
          () async {
        // Arrange - Firebase not initialized in test environment

        // Act
        final workout = await WorkoutService.createAutoWorkoutForUser(testUser);

        // Assert - Should return null due to Firebase error
        expect(workout, isNull);
      });

      test('getUserWorkouts should handle Firebase not initialized', () async {
        // Arrange - Firebase not initialized in test environment

        // Act
        final workouts = await WorkoutService.getUserWorkouts(testUser.id);

        // Assert - Should return empty list due to Firebase error
        expect(workouts, isEmpty);
      });
    });
  });
}
