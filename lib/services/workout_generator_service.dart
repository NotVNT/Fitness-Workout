import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/set_model.dart';

class WorkoutGeneratorService {
  // Tạo 7 ngày workout dựa trên BMI và mục tiêu của user
  static List<WorkoutModel> generate7DayWorkouts({
    required UserModel user,
    required List<ExerciseModel> availableExercises,
  }) {
    List<WorkoutModel> weeklyWorkouts = [];

    // Tạo workout cho 7 ngày
    for (int day = 0; day < 7; day++) {
      final workout = generateDailyWorkout(
        user: user,
        availableExercises: availableExercises,
        dayNumber: day + 1,
        startDate: DateTime.now().add(Duration(days: day)),
      );
      weeklyWorkouts.add(workout);
    }

    return weeklyWorkouts;
  }

  static WorkoutModel generateDailyWorkout({
    required UserModel user,
    required List<ExerciseModel> availableExercises,
    required int dayNumber,
    required DateTime startDate,
  }) {
    // Tính toán cường độ dựa trên BMI và mục tiêu
    final intensity = _calculateIntensity(user);
    final goal = _determineGoal(user);

    final selectedExercises =
        _selectDailyExercises(availableExercises, goal, intensity, dayNumber);

    final workoutExercises = selectedExercises.asMap().entries.map((entry) {
      int index = entry.key;
      ExerciseModel exercise = entry.value;

      final sets = _generateSetsForExercise(exercise, user, intensity);

      return WorkoutExercise(
        exerciseId: exercise.id,
        exercise: exercise,
        sets: sets,
        order: index + 1,
      );
    }).toList();

    // Tính tổng calories đốt cháy cho toàn bộ bài tập trong ngày
    final totalCalories = _estimateCaloriesForWorkout(
      user: user,
      workoutExercises: workoutExercises,
      goal: goal,
      intensity: intensity,
    );

    return WorkoutModel(
      id: "${DateTime.now().millisecondsSinceEpoch}_day$dayNumber",
      userId: user.id,
      name: "Ngày $dayNumber",
      description:
          "Workout ngày $dayNumber được tạo tự động dựa trên BMI ${user.bmi.toStringAsFixed(1)} và mục tiêu ${_getGoalDescription(goal)}",
      exercises: workoutExercises,
      startTime: startDate,
      status: 'planned',
      workoutType: goal,
      dayNumber: dayNumber,
      caloriesBurned: totalCalories,
    );
  }

  // Tính cường độ tập luyện (1.0 = dễ, 2.0 = trung bình, 3.0 = khó)
  static double _calculateIntensity(UserModel user) {
    double bmi = user.bmi;
    double weightDifference = (user.weight - user.targetWeight).abs();

    // Cường độ cơ bản dựa trên BMI
    double baseIntensity;
    if (bmi < 18.5) {
      baseIntensity = 1.2; // Gầy - cường độ thấp
    } else if (bmi < 25) {
      baseIntensity = 1.8; // Bình thường - cường độ trung bình
    } else if (bmi < 30) {
      baseIntensity = 1.5; // Thừa cân - cường độ thấp-trung bình
    } else {
      baseIntensity = 1.0; // Béo phì - cường độ thấp
    }

    // Điều chỉnh dựa trên mức độ cần giảm/tăng cân
    if (weightDifference > 10) {
      baseIntensity += 0.3; // Cần thay đổi nhiều -> tăng cường độ
    } else if (weightDifference > 5) {
      baseIntensity += 0.2;
    }

    // Giới hạn cường độ từ 1.0 đến 3.0
    return baseIntensity.clamp(1.0, 3.0);
  }

  // Xác định mục tiêu tập luyện
  static String _determineGoal(UserModel user) {
    // Tự động xác định dựa trên BMI và cân nặng mong muốn
    if (user.weight > user.targetWeight) {
      return 'lose_weight'; // Giảm cân
    } else if (user.weight < user.targetWeight) {
      return 'gain_muscle'; // Tăng cân/cơ bắp
    } else {
      return 'maintain'; // Duy trì
    }
  }

  // Lấy mô tả mục tiêu
  static String _getGoalDescription(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'giảm cân';
      case 'gain_muscle':
        return 'tăng cơ bắp';
      case 'maintain':
        return 'duy trì sức khỏe';
      default:
        return 'cải thiện thể lực';
    }
  }

  static List<ExerciseModel> _selectDailyExercises(
      List<ExerciseModel> exercises,
      String goal,
      double intensity,
      int dayNumber) {
    if (exercises.isEmpty) return [];

    // Lọc exercises phù hợp với mục tiêu
    List<ExerciseModel> suitableExercises =
        _filterExercisesByGoal(exercises, goal);

    // Nếu không có exercises phù hợp, sử dụng tất cả
    if (suitableExercises.isEmpty) {
      suitableExercises = exercises;
    }

    // Tạo pattern đa dạng dựa trên ngày
    List<ExerciseModel> selectedExercises =
        _createDailyPattern(suitableExercises, dayNumber);

    return selectedExercises.take(3).toList();
  }

  // Lọc exercises theo mục tiêu
  static List<ExerciseModel> _filterExercisesByGoal(
      List<ExerciseModel> exercises, String goal) {
    // Ưu tiên exercises theo tên
    List<String> preferredExercises;

    if (goal == 'lose_weight') {
      // Ưu tiên cardio và full-body exercises
      preferredExercises = [
        'jumping jack',
        'jump rope',
        'mountain climber',
        'jogging',
        'cycling',
        'burpee',
        'high knees',
        'running',
        'walking'
      ];
    } else if (goal == 'gain_muscle') {
      // Ưu tiên strength exercises
      preferredExercises = [
        'push-up',
        'squat',
        'plank',
        'sit-up',
        'pull-up',
        'deadlift',
        'bench press',
        'dumbbell'
      ];
    } else {
      // Maintain: cân bằng tất cả
      preferredExercises = [
        'push-up',
        'squat',
        'plank',
        'jumping jack',
        'walking',
        'sit-up',
        'mountain climber',
        'jogging'
      ];
    }

    // Lọc theo tên exercise (case-insensitive)
    List<ExerciseModel> filtered = exercises.where((exercise) {
      String exerciseName = exercise.name.toLowerCase();
      String vietnameseName = exercise.vietnameseName.toLowerCase();

      return preferredExercises.any((preferred) =>
          exerciseName.contains(preferred.toLowerCase()) ||
          vietnameseName.contains(preferred.toLowerCase()) ||
          preferred.toLowerCase().contains(exerciseName) ||
          preferred.toLowerCase().contains(vietnameseName));
    }).toList();

    // Nếu không tìm thấy exercises phù hợp, trả về tất cả
    return filtered.isNotEmpty ? filtered : exercises;
  }

  // Tạo pattern đa dạng cho mỗi ngày
  static List<ExerciseModel> _createDailyPattern(
      List<ExerciseModel> exercises, int dayNumber) {
    List<ExerciseModel> result = [];
    List<ExerciseModel> shuffled = List.from(exercises);

    // Tạo seed dựa trên ngày để có pattern cố định
    int seed = dayNumber * 7;

    // Shuffle exercises với seed
    for (int i = 0; i < shuffled.length; i++) {
      int j = (seed + i) % shuffled.length;
      ExerciseModel temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    // Chọn exercises đa dạng (tránh trùng lặp)
    Set<String> usedIds = {};
    for (ExerciseModel exercise in shuffled) {
      if (!usedIds.contains(exercise.id)) {
        result.add(exercise);
        usedIds.add(exercise.id);
        if (result.length >= 3) break;
      }
    }

    // Fallback nếu không đủ 3 exercises
    if (result.length < 3 && exercises.isNotEmpty) {
      for (int i = 0; i < exercises.length && result.length < 3; i++) {
        if (!usedIds.contains(exercises[i].id)) {
          result.add(exercises[i]);
          usedIds.add(exercises[i].id);
        }
      }
    }

    return result;
  }

  // Tạo sets cho từng bài tập
  static List<SetModel> _generateSetsForExercise(
      ExerciseModel exercise, UserModel user, double intensity) {
    List<SetModel> sets = [];

    // Set mặc định = 1 cho mỗi bài tập
    const int numSets = 1;

    for (int i = 1; i <= numSets; i++) {
      if (exercise.exerciseType == 'reps') {
        // Bài tập theo số lần
        int reps = _calculateReps(exercise, user, intensity, i);
        sets.add(SetModel(
          id: 'set_$i',
          setNumber: i,
          reps: reps,
          weight: 0.0, // Bodyweight exercises
          duration: null,
          restTime: _calculateRestTime(intensity),
        ));
      } else {
        // Bài tập theo thời gian
        int duration = _calculateDuration(exercise, user, intensity, i);
        sets.add(SetModel(
          id: 'set_$i',
          setNumber: i,
          reps: 0,
          weight: 0.0,
          duration: duration,
          restTime: _calculateRestTime(intensity),
        ));
      }
    }

    return sets;
  }

  // Tính số lần lặp lại
  static int _calculateReps(
      ExerciseModel exercise, UserModel user, double intensity, int setNumber) {
    // Base reps cho từng bài tập
    Map<String, int> baseReps = {
      'Push-up': 8,
      'Squat': 12,
      'Sit-up': 15,
      'Mountain Climber': 10,
    };

    int base = baseReps[exercise.name] ?? 10;

    // Điều chỉnh dựa trên BMI
    double bmi = user.bmi;
    if (bmi < 18.5) {
      base = (base * 0.7).round(); // Giảm cho người gầy
    } else if (bmi > 30) {
      base = (base * 0.6).round(); // Giảm cho người béo phì
    }

    // Điều chỉnh dựa trên cường độ
    base = (base * intensity * 0.8).round();

    // Set đầu nhiều hơn, set sau ít hơn
    double setMultiplier = 1.0 - (setNumber - 1) * 0.1;
    base = (base * setMultiplier).round();

    return base.clamp(3, 25);
  }

  // Tính thời gian (giây)
  static int _calculateDuration(
      ExerciseModel exercise, UserModel user, double intensity, int setNumber) {
    // Base duration cho từng bài tập (giây)
    Map<String, int> baseDuration = {
      'Plank': 30,
      'Jumping Jack': 45,
      'Jump Rope': 60,
      'Jogging': 120,
      'Cycling': 180,
      'Walking': 300,
    };

    int base = baseDuration[exercise.name] ?? 30;

    // Điều chỉnh dựa trên BMI
    double bmi = user.bmi;
    if (bmi < 18.5) {
      base = (base * 0.8).round();
    } else if (bmi > 30) {
      base = (base * 0.6).round();
    }

    // Điều chỉnh dựa trên cường độ
    base = (base * intensity * 0.9).round();

    // Set đầu dài hơn, set sau ngắn hơn
    double setMultiplier = 1.0 - (setNumber - 1) * 0.15;
    base = (base * setMultiplier).round();

    return base.clamp(15, 600); // 15 giây đến 10 phút
  }

  // Ước tính tổng calories đốt cháy cho toàn bộ workout trong ngày
  static int _estimateCaloriesForWorkout({
    required UserModel user,
    required List<WorkoutExercise> workoutExercises,
    required String goal,
    required double intensity,
  }) {
    double totalKcal = 0.0;
    final double userWeight = (user.weight <= 0) ? 65.0 : user.weight; // kg

    for (final we in workoutExercises) {
      final String name = we.exercise?.name ?? '';
      final double baseMet = _getBaseMetForExercise(name);
      final double met = _adjustMetForIntensity(baseMet, intensity, goal);

      for (final set in we.sets) {
        // Tính thời lượng set (giây)
        final int durationSeconds = set.duration ??
            _estimateDurationForReps(name: name, reps: set.reps);
        if (durationSeconds <= 0) continue;

        final double minutes = durationSeconds / 60.0;
        // Công thức chuẩn: kcal/phút = MET * 3.5 * cân nặng(kg) / 200
        final double kcal = (met * 3.5 * userWeight / 200.0) * minutes;
        totalKcal += kcal;
      }
    }

    // Làm tròn và giới hạn an toàn
    final int result = totalKcal.round().clamp(20, 3000);
    return result;
  }

  // MET cơ bản cho từng bài tập (ước lượng)
  static double _getBaseMetForExercise(String name) {
    final map = <String, double>{
      // Cardio nhẹ - vừa
      'Walking': 3.5,
      'Jogging': 7.0,
      'Cycling': 6.8,
      'Jump Rope': 11.0,
      'Jumping Jack': 8.0,
      'Mountain Climber': 8.0,
      // Sức mạnh/bodyweight
      'Push-up': 6.0,
      'Squat': 5.0,
      'Sit-up': 4.0,
      'Plank': 3.3,
    };

    // Tìm theo key khớp gần đúng (phòng khi có biến thể tên)
    for (final entry in map.entries) {
      if (name.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Mặc định nếu không khớp
    return 5.0;
  }

  // Điều chỉnh MET theo cường độ và mục tiêu
  static double _adjustMetForIntensity(
      double baseMet, double intensity, String goal) {
    // intensity: 1.0 - 3.0 => factor ~ 0.85 - 1.35
    final double intensityFactor =
        (0.85 + 0.25 * (intensity - 1)).clamp(0.75, 1.5);

    // Nếu mục tiêu là giảm cân, hơi tăng thêm cường độ đốt calo
    final double goalFactor = (goal == 'lose_weight') ? 1.05 : 1.0;

    return baseMet * intensityFactor * goalFactor;
  }

  // Ước tính thời lượng cho bài tập theo reps khi không có duration
  static int _estimateDurationForReps(
      {required String name, required int reps}) {
    if (reps <= 0) return 0;

    // Thời gian trung bình mỗi rep (giây)
    double secondsPerRep;
    final lower = name.toLowerCase();
    if (lower.contains('mountain climber')) {
      secondsPerRep = 1.0;
    } else if (lower.contains('sit-up') || lower.contains('sit up')) {
      secondsPerRep = 1.5;
    } else if (lower.contains('push-up') || lower.contains('push up')) {
      secondsPerRep = 2.0;
    } else if (lower.contains('squat')) {
      secondsPerRep = 2.0;
    } else {
      secondsPerRep = 1.5; // mặc định
    }

    final int totalSeconds = (reps * secondsPerRep).round();
    return totalSeconds.clamp(10, 600); // mỗi set tối thiểu 10s, tối đa 10 phút
  }

  // Tính thời gian nghỉ
  static int _calculateRestTime(double intensity) {
    // Cố định thời gian nghỉ: 60 giây cho mọi trường hợp
    return 60;
  }
}
