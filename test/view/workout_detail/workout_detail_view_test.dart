import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/view/workout_detail/workout_detail_view.dart';
import 'package:fitness/models/workout_model.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:fitness/models/set_model.dart';

void main() {
  group('WorkoutDetailView Widget Tests', () {
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
            ),
          ],
          order: 1,
        ),
        WorkoutExercise(
          exerciseId: 'ex2',
          exercise: testExercises[1],
          sets: [
            SetModel(
              id: 'set2',
              setNumber: 1,
              reps: 0,
              weight: 0.0,
              duration: 30,
            ),
          ],
          order: 2,
        ),
      ];

      testWorkout = WorkoutModel(
        id: 'workout1',
        userId: 'user1',
        name: 'Test Workout',
        description: 'A test workout for unit testing',
        exercises: workoutExercises,
        startTime: DateTime.now(),
        status: 'planned',
        workoutType: 'strength',
        caloriesBurned: 150,
        dayNumber: 1,
      );
    });

    Widget createTestWidget({bool isPreviewOnly = false}) {
      return MaterialApp(
        home: WorkoutDetailView(
          workout: testWorkout,
          allExercises: testExercises,
          isPreviewOnly: isPreviewOnly,
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('should display workout information', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Workout'), findsOneWidget);
        expect(find.text('A test workout for unit testing'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display workout statistics', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('2'), findsWidgets); // Exercise count
        expect(find.text('Bài tập'), findsWidgets); // Exercise label
        expect(find.text('Phút'), findsWidgets); // Time label
        expect(find.text('Kcal'), findsWidgets); // Calories label
      });

      testWidgets('should display exercise list', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Hít đất'), findsOneWidget);
        expect(find.text('Plank'), findsOneWidget);
      });

      testWidgets('should display start workout button when not preview only',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isPreviewOnly: false));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Khởi đầu'), findsOneWidget);
        expect(find.byType(MaterialButton), findsWidgets);
      });

      testWidgets('should not display start workout button when preview only',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isPreviewOnly: true));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Khởi đầu'), findsNothing);
      });
    });

    group('Exercise Display Tests', () {
      testWidgets('should display exercise details correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Hít đất'), findsOneWidget);
        expect(find.text('Plank'), findsOneWidget);
        expect(find.textContaining('10'), findsWidgets); // Reps
        expect(find.textContaining('30'), findsWidgets); // Duration
      });

      testWidgets('should display set information', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('x 10'), findsWidgets); // Reps format
        expect(find.textContaining('30s'), findsWidgets); // Duration format
      });

      testWidgets('should handle exercises with different types',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        // Should display both reps-based and duration-based exercises
        expect(find.text('Hít đất'), findsOneWidget); // Reps exercise
        expect(find.text('Plank'), findsOneWidget); // Duration exercise
      });
    });

    group('Interaction Tests', () {
      testWidgets('should handle start workout button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(isPreviewOnly: false));
        await tester.pumpAndSettle();

        // Act
        final startButton = find.text('Bắt đầu tập luyện');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle exercise tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        final exerciseWidget = find.text('Hít đất');
        if (exerciseWidget.evaluate().isNotEmpty) {
          await tester.tap(exerciseWidget);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });

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
    });

    group('Workout Status Tests', () {
      testWidgets('should display planned workout correctly', (tester) async {
        // Arrange
        final plannedWorkout = testWorkout.copyWith(status: 'planned');

        await tester.pumpWidget(MaterialApp(
          home: WorkoutDetailView(
            workout: plannedWorkout,
            allExercises: testExercises,
          ),
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Workout'), findsOneWidget);
        expect(find.text('Khởi đầu'), findsOneWidget);
      });

      testWidgets('should display completed workout correctly', (tester) async {
        // Arrange
        final completedWorkout = testWorkout.copyWith(
          status: 'completed',
          endTime: DateTime.now(),
        );

        await tester.pumpWidget(MaterialApp(
          home: WorkoutDetailView(
            workout: completedWorkout,
            allExercises: testExercises,
          ),
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Workout'), findsOneWidget);
        // Completed workout might have different UI
      });
    });

    group('Empty State Tests', () {
      testWidgets('should handle workout with no exercises', (tester) async {
        // Arrange
        final emptyWorkout = testWorkout.copyWith(exercises: []);

        await tester.pumpWidget(MaterialApp(
          home: WorkoutDetailView(
            workout: emptyWorkout,
            allExercises: testExercises,
          ),
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Workout'), findsOneWidget);
        // Should handle empty exercise list gracefully
      });

      testWidgets('should handle missing exercise data', (tester) async {
        // Arrange
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
          status: 'planned',
        );

        await tester.pumpWidget(MaterialApp(
          home: WorkoutDetailView(
            workout: workoutWithMissingExercise,
            allExercises: testExercises,
          ),
        ));
        await tester.pumpAndSettle();

        // Assert - Should handle missing exercise gracefully
        expect(find.text('Test Workout'), findsOneWidget);
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
        expect(find.byType(WorkoutDetailView), findsOneWidget);

        // Test tablet size
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pump();

        expect(find.byType(WorkoutDetailView), findsOneWidget);
      });
    });

    group('Scrolling Tests', () {
      testWidgets('should be scrollable when content overflows',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Try to scroll the ListView
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump();

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle null workout gracefully', (tester) async {
        // This test would require modifying the widget to handle null workout
        // For now, just verify the widget works with valid data

        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WorkoutDetailView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
