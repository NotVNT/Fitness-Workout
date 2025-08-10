import 'package:flutter_test/flutter_test.dart';

// Model tests
import 'models/workout_model_test.dart' as workout_model_tests;
import 'models/exercise_model_test.dart' as exercise_model_tests;
import 'models/set_model_test.dart' as set_model_tests;

// Service tests
import 'services/workout_generator_service_test.dart' as workout_generator_tests;
import 'services/workout_service_test.dart' as workout_service_tests;
import 'services/exercise_service_test.dart' as exercise_service_tests;

// View tests
import 'view/workout_tracker/workout_tracker_view_test.dart' as workout_tracker_view_tests;
import 'view/workout_detail/workout_detail_view_test.dart' as workout_detail_view_tests;
import 'view/workout_detail/workout_exercise_view_test.dart' as workout_exercise_view_tests;

void main() {
  group('🏋️ Workout Feature Tests', () {
    group('📋 Model Tests', () {
      group('WorkoutModel Tests', workout_model_tests.main);
      group('ExerciseModel Tests', exercise_model_tests.main);
      group('SetModel Tests', set_model_tests.main);
    });

    group('⚙️ Service Tests', () {
      group('WorkoutGeneratorService Tests', workout_generator_tests.main);
      group('WorkoutService Tests', workout_service_tests.main);
      group('ExerciseService Tests', exercise_service_tests.main);
    });

    group('🖥️ View Tests', () {
      group('WorkoutTrackerView Tests', workout_tracker_view_tests.main);
      group('WorkoutDetailView Tests', workout_detail_view_tests.main);
      group('WorkoutExerciseView Tests', workout_exercise_view_tests.main);
    });
  });
}
