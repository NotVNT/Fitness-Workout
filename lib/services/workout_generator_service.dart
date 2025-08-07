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

  // Tạo workout cho 1 ngày (5 bài tập)
  static WorkoutModel generateDailyWorkout({
    required UserModel user,
    required List<ExerciseModel> availableExercises,
    required int dayNumber,
    required DateTime startDate,
  }) {
    // Tính toán cường độ dựa trên BMI và mục tiêu
    final intensity = _calculateIntensity(user);
    final goal = _determineGoal(user);

    // Chọn 5 bài tập cho ngày này
    final selectedExercises =
        _selectDailyExercises(availableExercises, goal, intensity, dayNumber);

    // Tạo sets cho từng bài tập
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

    return WorkoutModel(
      id: "${DateTime.now().millisecondsSinceEpoch}_day$dayNumber",
      userId: user.id,
      name: "Ngày $dayNumber - ${_getDayName(dayNumber)}",
      description:
          "Workout ngày $dayNumber được tạo tự động dựa trên BMI ${user.bmi.toStringAsFixed(1)} và mục tiêu ${user.goal}",
      exercises: workoutExercises,
      startTime: startDate,
      status: 'planned',
      workoutType: goal,
      dayNumber: dayNumber,
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
    if (user.goal.isNotEmpty) {
      return user.goal; // Sử dụng mục tiêu đã chọn
    }

    // Tự động xác định dựa trên BMI và cân nặng mong muốn
    if (user.weight > user.targetWeight) {
      return 'lose_weight'; // Giảm cân
    } else if (user.weight < user.targetWeight) {
      return 'gain_muscle'; // Tăng cân/cơ bắp
    } else {
      return 'maintain'; // Duy trì
    }
  }

  // Chọn bài tập phù hợp với mục tiêu
  static List<ExerciseModel> _selectExercises(
      List<ExerciseModel> exercises, String goal, double intensity) {
    List<ExerciseModel> selected = [];

    if (goal == 'lose_weight') {
      // Ưu tiên cardio và bài tập đốt cháy calories
      selected.addAll(_getExercisesByName(exercises, [
        'Jumping Jack',
        'Jump Rope',
        'Mountain Climber',
        'Jogging',
        'Cycling',
        'Squat',
        'Push-up'
      ]));
    } else if (goal == 'gain_muscle') {
      // Ưu tiên strength training
      selected.addAll(_getExercisesByName(exercises, [
        'Push-up',
        'Squat',
        'Plank',
        'Sit-up',
        'Mountain Climber',
        'Jumping Jack'
      ]));
    } else {
      // Maintain - mix cả cardio và strength
      selected.addAll(_getExercisesByName(exercises,
          ['Push-up', 'Squat', 'Plank', 'Jumping Jack', 'Walking', 'Sit-up']));
    }

    // Giới hạn số lượng bài tập dựa trên cường độ
    int maxExercises = (intensity * 2).round().clamp(3, 6);
    return selected.take(maxExercises).toList();
  }

  // Chọn 5 bài tập cho từng ngày (đa dạng theo ngày)
  static List<ExerciseModel> _selectDailyExercises(
      List<ExerciseModel> exercises,
      String goal,
      double intensity,
      int dayNumber) {
    List<ExerciseModel> selected = [];

    // Danh sách bài tập theo mục tiêu
    List<String> exercisePool = [];

    if (goal == 'lose_weight') {
      exercisePool = [
        'Jumping Jack',
        'Jump Rope',
        'Mountain Climber',
        'Jogging',
        'Cycling',
        'Squat',
        'Push-up',
        'Walking',
        'Sit-up'
      ];
    } else if (goal == 'gain_muscle') {
      exercisePool = [
        'Push-up',
        'Squat',
        'Plank',
        'Sit-up',
        'Mountain Climber',
        'Jumping Jack',
        'Jump Rope'
      ];
    } else {
      exercisePool = [
        'Push-up',
        'Squat',
        'Plank',
        'Jumping Jack',
        'Walking',
        'Sit-up',
        'Mountain Climber',
        'Jogging'
      ];
    }

    // Tạo pattern khác nhau cho mỗi ngày
    List<String> dailyExercises =
        _getDailyExercisePattern(exercisePool, dayNumber);

    // Lấy exercises từ tên
    for (String exerciseName in dailyExercises) {
      try {
        final exercise = exercises.firstWhere((ex) => ex.name == exerciseName);
        selected.add(exercise);
      } catch (e) {
        // Nếu không tìm thấy, lấy exercise đầu tiên
        if (exercises.isNotEmpty) {
          selected.add(exercises.first);
        }
      }
    }

    // Đảm bảo có đúng 5 bài tập
    while (selected.length < 5 && exercises.isNotEmpty) {
      selected.add(exercises[selected.length % exercises.length]);
    }

    return selected.take(5).toList();
  }

  // Tạo pattern bài tập khác nhau cho mỗi ngày
  static List<String> _getDailyExercisePattern(
      List<String> exercisePool, int dayNumber) {
    // Shuffle exercises dựa trên ngày để tạo đa dạng
    List<String> shuffled = List.from(exercisePool);

    // Tạo seed dựa trên ngày để có pattern cố định cho mỗi ngày
    int seed = dayNumber * 7;

    // Simple shuffle algorithm với seed
    for (int i = 0; i < shuffled.length; i++) {
      int j = (seed + i) % shuffled.length;
      String temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled.take(5).toList();
  }

  // Lấy tên ngày
  static String _getDayName(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return "Thứ Hai";
      case 2:
        return "Thứ Ba";
      case 3:
        return "Thứ Tư";
      case 4:
        return "Thứ Năm";
      case 5:
        return "Thứ Sáu";
      case 6:
        return "Thứ Bảy";
      case 7:
        return "Chủ Nhật";
      default:
        return "Ngày $dayNumber";
    }
  }

  // Lấy bài tập theo tên
  static List<ExerciseModel> _getExercisesByName(
      List<ExerciseModel> exercises, List<String> names) {
    return names
        .map((name) => exercises.firstWhere(
              (ex) => ex.name == name,
              orElse: () => exercises.first,
            ))
        .toList();
  }

  // Tạo sets cho từng bài tập
  static List<SetModel> _generateSetsForExercise(
      ExerciseModel exercise, UserModel user, double intensity) {
    List<SetModel> sets = [];

    // Số sets dựa trên cường độ
    int numSets = (intensity + 1).round().clamp(2, 4);

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

  // Tính thời gian nghỉ
  static int _calculateRestTime(double intensity) {
    // Cường độ cao -> nghỉ lâu hơn
    int baseRest = (intensity * 30).round();
    return baseRest.clamp(30, 90); // 30-90 giây
  }
}
