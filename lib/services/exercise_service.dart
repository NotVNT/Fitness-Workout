import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  // Cache exercises tải từ Firestore để tra cứu nhanh
  static List<ExerciseModel> _cache = [];

  // Danh sách exercises mặc định (fallback nếu Firestore trống)
  static final List<ExerciseModel> _defaultExercises = [
    // Duration exercises
    ExerciseModel(
      id: 'plank',
      name: 'Plank',
      vietnameseName: 'Leo núi',
      description: 'Plank exercise for core strength',
      exerciseType: 'duration',
    ),
    ExerciseModel(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      vietnameseName: 'Leo núi',
      description: 'Mountain climbers exercise',
      exerciseType: 'duration',
    ),
    ExerciseModel(
      id: 'jumping_jacks',
      name: 'Jumping Jacks',
      vietnameseName: 'Bật nhảy tại chỗ',
      description: 'Jumping jacks exercise',
      exerciseType: 'duration',
    ),
    ExerciseModel(
      id: 'high_knees',
      name: 'High Knees',
      vietnameseName: 'Chạy tại chỗ nâng cao đầu gối',
      description: 'High knees running in place',
      exerciseType: 'duration',
    ),
    ExerciseModel(
      id: 'burpees',
      name: 'Burpees',
      vietnameseName: 'Burpees',
      description: 'Full body burpees exercise',
      exerciseType: 'duration',
    ),

    // Reps exercises
    ExerciseModel(
      id: 'chair_dips',
      name: 'Chair Dips',
      vietnameseName: 'Tập cơ tay sau trên ghế',
      description: 'Chair dips for triceps',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'push_ups',
      name: 'Push Ups',
      vietnameseName: 'Hít đất',
      description: 'Standard push ups',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'squats',
      name: 'Squats',
      vietnameseName: 'Squat',
      description: 'Bodyweight squats',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'lunges',
      name: 'Lunges',
      vietnameseName: 'Lunge',
      description: 'Forward lunges',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'sit_ups',
      name: 'Sit Ups',
      vietnameseName: 'Gập bụng',
      description: 'Standard sit ups',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'crunches',
      name: 'Crunches',
      vietnameseName: 'Gập bụng nhẹ',
      description: 'Abdominal crunches',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'wall_sit',
      name: 'Wall Sit',
      vietnameseName: 'Ngồi tựa tường',
      description: 'Wall sit exercise',
      exerciseType: 'duration',
    ),
    ExerciseModel(
      id: 'tricep_dips',
      name: 'Tricep Dips',
      vietnameseName: 'Chống đẩy tay sau',
      description: 'Tricep dips exercise',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'step_ups',
      name: 'Step Ups',
      vietnameseName: 'Bước lên bậc',
      description: 'Step up exercise',
      exerciseType: 'reps',
    ),
    ExerciseModel(
      id: 'side_plank',
      name: 'Side Plank',
      vietnameseName: 'Plank nghiêng',
      description: 'Side plank exercise',
      exerciseType: 'duration',
    ),
  ];

  // Get all exercises (load once, cache)
  Future<List<ExerciseModel>> getAllExercises() async {
    if (_cache.isNotEmpty) return _cache;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();
      if (snapshot.docs.isNotEmpty) {
        _cache = snapshot.docs
            .map((doc) => ExerciseModel.fromFirestore(doc))
            .toList();
        return _cache;
      }
    } catch (e) {
      print('🏋️ ExerciseService: Lỗi khi lấy exercises từ Firestore: $e');
    }

    // Fallback to default list if Firestore failed or empty
    _cache = List<ExerciseModel>.from(_defaultExercises);
    return _cache;
  }

  // Get exercise by ID (use cache and fallback)
  ExerciseModel? getExerciseById(String exerciseId) {
    try {
      return _defaultExercises
          .firstWhere((exercise) => exercise.id == exerciseId);
    } catch (e) {
      print('🏋️ ExerciseService: Không tìm thấy exercise với ID: $exerciseId');
      return null;
    }
  }

  // Get exercises by type
  Future<List<ExerciseModel>> getExercisesByType(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _defaultExercises
        .where((exercise) => exercise.exerciseType == type)
        .toList();
  }

  // Search exercises
  Future<List<ExerciseModel>> searchExercises(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _defaultExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowercaseQuery) ||
          exercise.vietnameseName.toLowerCase().contains(lowercaseQuery) ||
          exercise.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get random exercises
  Future<List<ExerciseModel>> getRandomExercises(int count) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final shuffled = List<ExerciseModel>.from(_defaultExercises)..shuffle();
    return shuffled.take(count).toList();
  }
}
