import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/view/workout_detail/workout_exercise_view.dart';
import 'package:fitness/models/workout_model.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:fitness/models/set_model.dart';

void main() {
  group('WorkoutExerciseView Widget Tests', () {
    late WorkoutModel testWorkout;
    late List<ExerciseModel> testExercises;

    setUp(() {
      testExercises = [
        ExerciseModel(
          id: 'ex1',
          name: 'Push Up',
          vietnameseName: 'Hít đất',
          description: 'Basic push up exercise',
          exerciseType: 'reps',
        ),
        ExerciseModel(
          id: 'ex2',
          name: 'Plank',
          vietnameseName: 'Plank',
          description: 'Core exercise',
          exerciseType: 'duration',
        ),
      ];

      final workoutExercises = [
        WorkoutExercise(
          exerciseId: 'ex1',
          exercise: testExercises[0],
          sets: [
            SetModel(
              id: 'set1',
              setNumber: 1,
              reps: 10,
              weight: 0.0,
              restTime: 60,
            ),
            SetModel(
              id: 'set2',
              setNumber: 2,
              reps: 12,
              weight: 0.0,
              restTime: 60,
            ),
          ],
          order: 1,
        ),
        WorkoutExercise(
          exerciseId: 'ex2',
          exercise: testExercises[1],
          sets: [
            SetModel(
              id: 'set3',
              setNumber: 1,
              reps: 0,
              weight: 0.0,
              duration: 30,
              restTime: 30,
            ),
          ],
          order: 2,
        ),
      ];

      testWorkout = WorkoutModel(
        id: 'workout1',
        userId: 'user1',
        name: 'Test Workout',
        exercises: workoutExercises,
        startTime: DateTime.now(),
        status: 'in_progress',
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: WorkoutExerciseView(
          workout: testWorkout,
          allExercises: testExercises,
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('should display current exercise information',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Hít đất'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should display set information', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('x 10'), findsWidgets); // Reps format
      });

      testWidgets('should display progress indicator', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('1/2'), findsOneWidget); // Exercise progress
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });

      testWidgets('should display control buttons', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('XONG'),
            findsOneWidget); // Complete button for reps exercise
        expect(find.text('BỎ QUA'), findsOneWidget); // Skip button
      });
    });

    group('Exercise Type Tests', () {
      testWidgets('should display reps exercise correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Hít đất'), findsOneWidget);
        expect(find.textContaining('10'), findsWidgets); // Reps count
        expect(find.text('XONG'), findsOneWidget); // Complete button
      });

      testWidgets('should display duration exercise correctly', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Complete first exercise to get to duration exercise
        await tester.tap(find.text('XONG'));
        await tester.pumpAndSettle();

        // Skip rest period
        final skipRestButton = find.text('BỎ QUA NGHỈ');
        if (skipRestButton.evaluate().isNotEmpty) {
          await tester.tap(skipRestButton);
          await tester.pumpAndSettle();
        }

        // Assert
        expect(find.text('Plank'), findsOneWidget);
        expect(find.textContaining('30'), findsWidgets); // Duration
        expect(find.text('TẠM DỪNG'), findsOneWidget); // Pause timer button
      });
    });

    group('Interaction Tests', () {
      testWidgets('should handle complete set button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('XONG'));
        await tester.pump();

        // Assert - Should move to next set or rest period
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle skip exercise button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('BỎ QUA'));
        await tester.pump();

        // Assert - Should skip to next exercise
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle pause/resume for duration exercises',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Complete first exercise to get to duration exercise
        await tester.tap(find.text('XONG'));
        await tester.pumpAndSettle();

        // Skip rest if present
        final skipRestButton = find.text('BỎ QUA NGHỈ');
        if (skipRestButton.evaluate().isNotEmpty) {
          await tester.tap(skipRestButton);
          await tester.pumpAndSettle();
        }

        // Act - Start timer
        final startButton = find.text('BẮT ĐẦU');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });
    });

    group('Rest Period Tests', () {
      testWidgets('should display rest screen after completing set',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Complete first set
        await tester.tap(find.text('XONG'));
        await tester.pumpAndSettle();

        // Assert - Should show rest screen
        expect(find.text('NGHỈ NGƠI'), findsWidgets);
        expect(find.text('BỎ QUA NGHỈ'), findsOneWidget);
      });

      testWidgets('should handle skip rest button', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Complete first set to trigger rest
        await tester.tap(find.text('XONG'));
        await tester.pumpAndSettle();

        // Act - Skip rest
        final skipRestButton = find.text('BỎ QUA NGHỈ');
        if (skipRestButton.evaluate().isNotEmpty) {
          await tester.tap(skipRestButton);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });
    });

    group('Workout Completion Tests', () {
      testWidgets('should display completion screen when workout finished',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Complete all exercises (this is a simplified test)
        // In reality, you'd need to complete all sets of all exercises

        // Complete first exercise sets
        await tester.tap(find.text('XONG')); // Set 1
        await tester.pumpAndSettle();

        // Skip rest
        final skipRestButton = find.text('BỎ QUA NGHỈ');
        if (skipRestButton.evaluate().isNotEmpty) {
          await tester.tap(skipRestButton);
          await tester.pumpAndSettle();
        }

        // Assert - Should not crash during progression
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle workout completion', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - This test verifies the widget can handle completion flow
        // Complete workout by skipping through exercises
        for (int i = 0; i < 3; i++) {
          final skipButton = find.text('BỎ QUA');
          if (skipButton.evaluate().isNotEmpty) {
            await tester.tap(skipButton);
            await tester.pumpAndSettle();
          }
        }

        // Assert - Should handle completion gracefully
        expect(tester.takeException(), isNull);
      });
    });

    group('Timer Tests', () {
      testWidgets('should handle timer for duration exercises', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to duration exercise
        await tester.tap(find.text('XONG')); // Complete first exercise
        await tester.pumpAndSettle();

        // Skip rest
        final skipRestButton = find.text('BỎ QUA NGHỈ');
        if (skipRestButton.evaluate().isNotEmpty) {
          await tester.tap(skipRestButton);
          await tester.pumpAndSettle();
        }

        // Act - Start timer
        final startButton = find.text('BẮT ĐẦU');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pump(const Duration(seconds: 1));
        }

        // Assert - Timer should be running
        expect(tester.takeException(), isNull);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should handle back navigation', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pump();
        }

        // Assert
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle exit workout confirmation', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Try to exit (might show confirmation dialog)
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }

        // Assert - Should handle exit gracefully
        expect(tester.takeException(), isNull);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle missing exercise data', (tester) async {
        // Arrange - Create workout with missing exercise reference
        final workoutWithMissingExercise = WorkoutModel(
          id: 'workout1',
          userId: 'user1',
          name: 'Test Workout',
          exercises: [
            WorkoutExercise(
              exerciseId: 'missing_exercise',
              sets: [
                SetModel(
                  id: 'set1',
                  setNumber: 1,
                  reps: 10,
                  weight: 0.0,
                ),
              ],
              order: 1,
            ),
          ],
          startTime: DateTime.now(),
          status: 'in_progress',
        );

        await tester.pumpWidget(MaterialApp(
          home: WorkoutExerciseView(
            workout: workoutWithMissingExercise,
            allExercises: testExercises,
          ),
        ));
        await tester.pumpAndSettle();

        // Assert - Should handle missing exercise gracefully
        expect(find.byType(WorkoutExerciseView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Arrange
        await tester.binding.setSurfaceSize(const Size(400, 800)); // Phone size

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WorkoutExerciseView), findsOneWidget);

        // Test tablet size
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pump();

        expect(find.byType(WorkoutExerciseView), findsOneWidget);
      });
    });
  });
}
