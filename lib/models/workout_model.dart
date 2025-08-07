import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_model.dart';
import 'exercise_model.dart';

class WorkoutExercise {
  final String exerciseId;
  final ExerciseModel?
      exercise; // Thông tin bài tập (có thể null nếu chỉ lưu ID)
  final List<SetModel> sets; // Danh sách các set
  final String? notes; // Ghi chú cho bài tập này trong workout
  final int order; // Thứ tự bài tập trong workout

  WorkoutExercise({
    required this.exerciseId,
    this.exercise,
    required this.sets,
    this.notes,
    required this.order,
  });

  // Factory constructor from Map
  factory WorkoutExercise.fromMap(Map<String, dynamic> data) {
    List<SetModel> sets = [];
    if (data['sets'] != null) {
      List<dynamic> setsData = data['sets'];
      sets = setsData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> setData = entry.value;
        return SetModel.fromMap(setData, 'set_$index');
      }).toList();
    }

    return WorkoutExercise(
      exerciseId: data['exerciseId'] ?? '',
      sets: sets,
      notes: data['notes'],
      order: data['order'] ?? 0,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'sets': sets.map((set) => set.toMap()).toList(),
      'notes': notes,
      'order': order,
    };
  }

  // Get total sets count
  int get totalSets => sets.length;

  // Get completed sets count
  int get completedSets => sets.where((set) => set.isCompleted).length;

  // Get total volume for this exercise
  double get totalVolume => sets.fold(0.0, (sum, set) => sum + set.volume);

  // Check if exercise is completed
  bool get isCompleted =>
      sets.isNotEmpty && sets.every((set) => set.isCompleted);
}

class WorkoutModel {
  final String id;
  final String userId;
  final String name; // Tên workout
  final String? description; // Mô tả workout
  final List<WorkoutExercise> exercises; // Danh sách bài tập
  final DateTime startTime; // Thời gian bắt đầu
  final DateTime? endTime; // Thời gian kết thúc
  final int? duration; // Thời gian tập (phút)
  final String status; // 'planned', 'in_progress', 'completed', 'cancelled'
  final String? workoutType; // 'strength', 'cardio', 'mixed', etc.
  final int? caloriesBurned; // Calories đã đốt cháy
  final String? notes; // Ghi chú chung cho workout
  final int? dayNumber; // Ngày thứ mấy trong tuần (1-7)
  final Map<String, dynamic>? metadata; // Dữ liệu bổ sung

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.exercises,
    required this.startTime,
    this.endTime,
    this.duration,
    this.status = 'planned',
    this.workoutType,
    this.caloriesBurned,
    this.notes,
    this.dayNumber,
    this.metadata,
  });

  // Factory constructor from Firestore
  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<WorkoutExercise> exercises = [];
    if (data['exercises'] != null) {
      List<dynamic> exercisesData = data['exercises'];
      exercises = exercisesData.map((exerciseData) {
        return WorkoutExercise.fromMap(exerciseData);
      }).toList();
    }

    return WorkoutModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      exercises: exercises,
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      duration: data['duration'],
      status: data['status'] ?? 'planned',
      workoutType: data['workoutType'],
      caloriesBurned: data['caloriesBurned'],
      notes: data['notes'],
      dayNumber: data['dayNumber'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'status': status,
      'workoutType': workoutType,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'dayNumber': dayNumber,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? status,
    String? workoutType,
    int? caloriesBurned,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      workoutType: workoutType ?? this.workoutType,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get total exercises count
  int get totalExercises => exercises.length;

  // Get completed exercises count
  int get completedExercises => exercises.where((ex) => ex.isCompleted).length;

  // Get total sets count
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.totalSets);

  // Get completed sets count
  int get completedSets =>
      exercises.fold(0, (sum, ex) => sum + ex.completedSets);

  // Get total volume
  double get totalVolume =>
      exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);

  // Check if workout is completed
  bool get isCompleted => status == 'completed';

  // Get workout progress percentage
  double get progressPercentage {
    if (totalSets == 0) return 0.0;
    return (completedSets / totalSets) * 100;
  }

  @override
  String toString() {
    return 'WorkoutModel(id: $id, name: $name, status: $status, exercises: ${exercises.length})';
  }
}
