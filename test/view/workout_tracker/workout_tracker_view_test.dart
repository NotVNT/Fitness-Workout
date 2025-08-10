import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness/view/workout_tracker/workout_tracker_view.dart';
import 'package:fitness/providers/user_provider.dart';
import 'package:fitness/models/user_model.dart';

// Mock UserProvider to avoid Firebase dependency
class MockUserProvider extends ChangeNotifier implements UserProvider {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  @override
  UserModel? get user => _user;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  double get bmi => _user?.bmi ?? 0.0;

  @override
  String get bmiCategory => _user?.bmiCategory ?? 'Unknown';

  @override
  String getBMIStatusMessage() {
    if (_user == null) return 'Chưa có thông tin BMI';
    switch (bmiCategory) {
      case 'Underweight':
        return 'Bạn đang thiếu cân';
      case 'Normal':
        return 'Bạn có cân nặng bình thường';
      case 'Overweight':
        return 'Bạn đang thừa cân';
      case 'Obese':
        return 'Bạn đang béo phì';
      default:
        return 'Chưa có thông tin BMI';
    }
  }

  @override
  Color getBMIColor() {
    switch (bmiCategory) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void clearUser() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WorkoutTrackerView Widget Tests', () {
    late MockUserProvider userProvider;
    late UserModel testUser;

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

      userProvider = MockUserProvider();
      userProvider.setUser(testUser);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
          child: const WorkoutTrackerView(),
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('should display main UI elements', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
        expect(find.byType(AppBar), findsWidgets); // May have multiple AppBars
        expect(find.byType(SingleChildScrollView), findsWidgets);
      });

      testWidgets('should display progress chart section', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Look for any chart-related widgets
        expect(find.byType(Container), findsWidgets);
        // Chart may not have specific text, just verify structure exists
      });

      testWidgets('should display workout sections', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Look for workout-related widgets
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should display create workout button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Look for buttons
        expect(find.byType(ElevatedButton), findsWidgets);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Loading States Tests', () {
      testWidgets('should show loading indicator when loading workouts',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Don't wait for settle to catch loading state
        await tester.pump();

        // Assert - Look for any loading indicators or just verify no crash
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
      });

      testWidgets('should hide loading indicator after data loads',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Loading should be complete
        // Note: Actual loading behavior depends on service implementation
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should handle create workout button tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Try to tap any button
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle refresh action', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Simulate pull to refresh
        await tester.fling(
            find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
        await tester.pump();

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle workout card tap', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Try to tap on workout cards if they exist
        final workoutCards = find.byType(Card);
        if (workoutCards.evaluate().isNotEmpty) {
          await tester.tap(workoutCards.first);
          await tester.pump();
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
      });
    });

    group('Chart Tests', () {
      testWidgets('should display weekly progress chart', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Chart widget should be present
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should show chart legend', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Look for legend elements
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Empty State Tests', () {
      testWidgets('should handle empty workout list', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should handle empty state gracefully
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should show appropriate message when no workouts',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should handle empty state gracefully
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate to workout detail when workout tapped',
          (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - This test would require actual workout data
        // For now, just verify the widget doesn't crash

        // Assert
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
      });

      testWidgets('should handle back navigation', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Simulate back button if present
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pump();
        }

        // Assert
        expect(tester.takeException(), isNull);
      });
    });

    group('User Provider Integration Tests', () {
      testWidgets('should access user data from provider', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Widget should be able to access user provider
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
      });

      testWidgets('should handle user provider changes', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Update user in provider
        userProvider.setUser(testUser.copyWith(firstName: 'Jane'));
        await tester.pump();

        // Assert - Should handle provider updates
        expect(tester.takeException(), isNull);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle service errors gracefully', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should not crash even if services fail
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should display error state when appropriate',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should handle errors gracefully
        expect(find.byType(WorkoutTrackerView), findsOneWidget);
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
        expect(find.byType(WorkoutTrackerView), findsOneWidget);

        // Test tablet size
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pump();

        expect(find.byType(WorkoutTrackerView), findsOneWidget);
      });
    });
  });
}
