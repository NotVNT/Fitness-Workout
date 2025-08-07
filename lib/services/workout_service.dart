import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../models/user_model.dart';
import '../models/exercise_model.dart';
import 'workout_generator_service.dart';

class WorkoutService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String usersCollection = 'users';
  static const String workoutsSubcollection = 'workouts';
  static const String exercisesCollection = 'exercises';

  // Tạo 7 ngày workout tự động cho user
  static Future<List<WorkoutModel>?> create7DayWorkoutsForUser(
      UserModel user) async {
    try {
      print(
          '🔥 WorkoutService: Tạo workout tự động cho user: ${user.fullName}');
      print(
          '🔥 WorkoutService: User BMI: ${user.bmi.toStringAsFixed(1)}, Weight: ${user.weight}kg, Target: ${user.targetWeight}kg');

      // Lấy danh sách bài tập từ Firestore
      print('🔥 WorkoutService: Đang lấy exercises từ Firestore...');
      final exercisesSnapshot =
          await _firestore.collection(exercisesCollection).get();

      print(
          '🔥 WorkoutService: Số documents trong exercises collection: ${exercisesSnapshot.docs.length}');

      if (exercisesSnapshot.docs.isEmpty) {
        print('❌ WorkoutService: Không có bài tập nào trong database');
        return null;
      }

      // Convert sang ExerciseModel
      print('🔥 WorkoutService: Đang convert documents sang ExerciseModel...');
      List<ExerciseModel> exercises = [];

      for (var doc in exercisesSnapshot.docs) {
        try {
          final exercise = ExerciseModel.fromFirestore(doc);
          exercises.add(exercise);
          print(
              '🔥 WorkoutService: Loaded exercise: ${exercise.name} (${exercise.exerciseType})');
        } catch (e) {
          print('❌ WorkoutService: Lỗi convert exercise ${doc.id}: $e');
        }
      }

      print('🔥 WorkoutService: Tổng cộng ${exercises.length} bài tập hợp lệ');

      if (exercises.isEmpty) {
        print('❌ WorkoutService: Không có bài tập hợp lệ nào');
        return null;
      }

      // Tạo 7 ngày workouts
      print(
          '🔥 WorkoutService: Đang tạo 7 ngày workouts với WorkoutGeneratorService...');
      List<WorkoutModel> weeklyWorkouts =
          WorkoutGeneratorService.generate7DayWorkouts(
        user: user,
        availableExercises: exercises,
      );

      print(
          '🔥 WorkoutService: Đã tạo ${weeklyWorkouts.length} workouts cho 7 ngày');

      // Lưu tất cả workouts vào Firestore subcollection
      print(
          '🔥 WorkoutService: Đang lưu ${weeklyWorkouts.length} workouts vào user subcollection...');

      final batch = _firestore.batch();
      for (var workout in weeklyWorkouts) {
        final docRef = _firestore
            .collection(usersCollection)
            .doc(user.id)
            .collection(workoutsSubcollection)
            .doc(workout.id);
        batch.set(docRef, workout.toMap());
        print('🔥 WorkoutService: Thêm ${workout.name} vào batch');
      }

      await batch.commit();

      print(
          '✅ WorkoutService: Đã lưu tất cả ${weeklyWorkouts.length} workouts thành công vào user/${user.id}/workouts');
      return weeklyWorkouts;
    } catch (e) {
      print('❌ WorkoutService: Lỗi khi tạo workout: $e');
      print('❌ WorkoutService: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Tạo workout tự động cho user (backward compatibility)
  static Future<WorkoutModel?> createAutoWorkoutForUser(UserModel user) async {
    final workouts = await create7DayWorkoutsForUser(user);
    if (workouts != null && workouts.isNotEmpty) {
      return workouts.first; // Trả về workout đầu tiên
    }
    return null;
  }

  // Lấy workouts của user từ subcollection
  static Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .orderBy('startTime', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Lỗi khi lấy workouts: $e');
      return [];
    }
  }

  // Lấy workout theo ngày hiện tại (dựa trên dayNumber)
  static Future<WorkoutModel?> getTodayWorkout(String userId) async {
    try {
      // Tính ngày hiện tại trong tuần (1-7)
      final today = DateTime.now();
      final firstWorkoutDate = await _getFirstWorkoutDate(userId);

      if (firstWorkoutDate == null) {
        print('🏋️ WorkoutService: Chưa có workout nào được tạo');
        return null;
      }

      // Tính số ngày đã trôi qua kể từ ngày đầu tiên
      final daysPassed = today.difference(firstWorkoutDate).inDays;
      final currentDayNumber = (daysPassed % 7) + 1; // 1-7, lặp lại sau 7 ngày

      print(
          '🏋️ WorkoutService: Ngày đầu tiên: ${firstWorkoutDate.day}/${firstWorkoutDate.month}');
      print('🏋️ WorkoutService: Hôm nay: ${today.day}/${today.month}');
      print('🏋️ WorkoutService: Số ngày đã trôi qua: $daysPassed');
      print('🏋️ WorkoutService: Ngày hiện tại trong tuần: $currentDayNumber');

      // Lấy workout theo dayNumber
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .where('dayNumber', isEqualTo: currentDayNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final workout = WorkoutModel.fromFirestore(snapshot.docs.first);
        print('🏋️ WorkoutService: Tìm thấy workout hôm nay: ${workout.name}');
        return workout;
      } else {
        print(
            '🏋️ WorkoutService: Không tìm thấy workout cho ngày $currentDayNumber');
        return null;
      }
    } catch (e) {
      print('❌ WorkoutService: Lỗi khi lấy workout hôm nay: $e');
      return null;
    }
  }

  // Lấy ngày của workout đầu tiên
  static Future<DateTime?> _getFirstWorkoutDate(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .where('dayNumber', isEqualTo: 1)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final workout = WorkoutModel.fromFirestore(snapshot.docs.first);
        return workout.startTime;
      }
      return null;
    } catch (e) {
      print('❌ WorkoutService: Lỗi khi lấy ngày workout đầu tiên: $e');
      return null;
    }
  }

  // Cập nhật workout
  static Future<bool> updateWorkout(WorkoutModel workout) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(workout.userId)
          .collection(workoutsSubcollection)
          .doc(workout.id)
          .update(workout.toMap());
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật workout: $e');
      return false;
    }
  }

  // Đánh dấu workout hoàn thành
  static Future<bool> completeWorkout(String userId, String workoutId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .doc(workoutId)
          .update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Lỗi khi hoàn thành workout: $e');
      return false;
    }
  }

  // Xóa workout
  static Future<bool> deleteWorkout(String userId, String workoutId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(workoutsSubcollection)
          .doc(workoutId)
          .delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa workout: $e');
      return false;
    }
  }

  // Tạo workout mẫu cho demo
  static Future<void> createSampleWorkout(UserModel user) async {
    try {
      // Tạo workout đơn giản cho demo
      final sampleWorkout = WorkoutModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        name: "Workout mẫu",
        description: "Workout cơ bản để bắt đầu",
        exercises: [], // Sẽ được thêm sau
        startTime: DateTime.now(),
        status: 'planned',
        workoutType: 'mixed',
      );

      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .collection(workoutsSubcollection)
          .doc(sampleWorkout.id)
          .set(sampleWorkout.toMap());

      print('Đã tạo workout mẫu');
    } catch (e) {
      print('Lỗi khi tạo workout mẫu: $e');
    }
  }
}
