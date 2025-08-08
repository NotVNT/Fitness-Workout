class SetModel {
  final String id;
  final int setNumber; // Set thứ mấy (1, 2, 3...)
  final int reps; // Số lần lặp lại
  final double weight; // Trọng lượng (kg)
  final int? duration; // Thời gian (giây) - cho bài tập thời gian
  final int? restTime; // Thời gian nghỉ (giây)
  final bool isCompleted; // Đã hoàn thành set này chưa

  SetModel({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.duration,
    this.restTime,
    this.isCompleted = false,
  });

  // Factory constructor from Map
  factory SetModel.fromMap(Map<String, dynamic> data, String id) {
    return SetModel(
      id: id,
      setNumber: data['setNumber'] ?? 1,
      reps: data['reps'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      duration: data['duration'],
      restTime: data['restTime'],
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'restTime': restTime,
      'isCompleted': isCompleted,
    };
  }

  // Copy with method
  SetModel copyWith({
    String? id,
    int? setNumber,
    int? reps,
    double? weight,
    int? duration,
    int? restTime,
    bool? isCompleted,
  }) {
    return SetModel(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Get formatted weight string (always in kg)
  String get formattedWeight {
    return '${weight.toStringAsFixed(1)} kg';
  }

  // Get total volume (weight × reps)
  double get volume {
    return weight * reps;
  }

  @override
  String toString() {
    return 'SetModel(setNumber: $setNumber, reps: $reps, weight: ${weight}kg, completed: $isCompleted)';
  }
}
