import 'package:flutter_test/flutter_test.dart';

// Model tests
import 'models/user_model_test.dart' as user_model_tests;
import 'models/workout_model_test.dart' as workout_model_tests;
import 'models/exercise_model_test.dart' as exercise_model_tests;
import 'models/set_model_test.dart' as set_model_tests;
import 'models/sleep_schedule_test.dart' as sleep_schedule_tests;

// Service tests
import 'services/exercise_service_test.dart' as exercise_service_tests;
import 'services/workout_generator_service_test.dart'
    as workout_generator_tests;
import 'services/workout_service_test.dart' as workout_service_tests;
import 'services/workout_reminder_service_test.dart' as workout_reminder_tests;
import 'services/sleep_schedule_service_test.dart'
    as sleep_schedule_service_tests;
import 'services/firestore_service_test.dart' as firestore_service_tests;

// Provider tests
// import 'providers/user_provider_test.dart' as user_provider_tests;

// Common widget tests
import 'common_widget/round_button_test.dart' as round_button_tests;
import 'common_widget/round_textfield_test.dart' as round_textfield_tests;

// View tests
import 'view/login/login_view_test.dart' as login_view_tests;
import 'view/workout_tracker/workout_tracker_view_test.dart'
    as workout_tracker_view_tests;
import 'view/workout_detail/workout_detail_view_test.dart'
    as workout_detail_view_tests;
import 'view/workout_detail/workout_exercise_view_test.dart'
    as workout_exercise_view_tests;

void main() {
  group('🏃‍♂️ Fitness App - Complete Test Suite', () {
    group('📋 Model Tests', () {
      group('👤 UserModel Tests', user_model_tests.main);
      group('🏋️ WorkoutModel Tests', workout_model_tests.main);
      group('💪 ExerciseModel Tests', exercise_model_tests.main);
      group('🔢 SetModel Tests', set_model_tests.main);
      group('😴 SleepSchedule Tests', sleep_schedule_tests.main);
    });

    group('⚙️ Service Tests', () {
      group('💪 ExerciseService Tests', exercise_service_tests.main);
      group('🎯 WorkoutGeneratorService Tests', workout_generator_tests.main);
      group('🏋️ WorkoutService Tests', workout_service_tests.main);
      group('⏰ WorkoutReminderService Tests', workout_reminder_tests.main);
      group('😴 SleepScheduleService Tests', sleep_schedule_service_tests.main);
      group('🔥 FirestoreService Tests', firestore_service_tests.main);
    });

    // group('🔄 Provider Tests', () {
    //   group('👤 UserProvider Tests', user_provider_tests.main);
    // });

    group('🎨 Common Widget Tests', () {
      group('🔘 RoundButton Tests', round_button_tests.main);
      group('📝 RoundTextField Tests', round_textfield_tests.main);
    });

    group('🖥️ View Tests', () {
      group('🔐 LoginView Tests', login_view_tests.main);
      group('📊 WorkoutTrackerView Tests', workout_tracker_view_tests.main);
      group('📋 WorkoutDetailView Tests', workout_detail_view_tests.main);
      group(
          '🏃‍♂️ WorkoutExerciseView Tests', workout_exercise_view_tests.main);
    });
  });
}
