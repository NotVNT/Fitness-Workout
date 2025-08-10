import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String vietnameseName;
  final String description;
  final String exerciseType; // 'reps' hoặc 'duration'
  final String? imageUrl; // URL ảnh (nếu dùng Storage)
  final String?
      imageAsset;


  ExerciseModel({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.description,
    required this.exerciseType,
    this.imageUrl,

    this.imageAsset,

  });

  // Factory constructor from Firestore
  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;


    String? sanitizeAsset(dynamic v) {
      if (v is! String) return null;
      var t = v.trim();
      if (t.length >= 2) {
        final hasDouble = t.startsWith('"') && t.endsWith('"');
        final hasSingle = t.startsWith("'") && t.endsWith("'");
        if (hasDouble || hasSingle) {
          t = t.substring(1, t.length - 1).trim();
        }
      }
      return t;
    }

    return ExerciseModel(
      // Ưu tiên field 'id' trong doc để khớp với workoutExercise.exerciseId; fallback = doc.id
      id: (data['id'] ?? doc.id) as String,

      name: data['name'] ?? '',
      vietnameseName: data['vietnameseName'] ?? '',
      description: data['description'] ?? '',
      exerciseType: data['exerciseType'] ?? 'reps',
      imageUrl: data['imageUrl'],
      imageAsset: sanitizeAsset(data['imageAsset']),

    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vietnameseName': vietnameseName,
      'description': description,
      'exerciseType': exerciseType,
      'imageUrl': imageUrl,
      'imageAsset': imageAsset,

    };
  }

  // Copy with method
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? vietnameseName,
    String? description,
    String? exerciseType,
    String? imageUrl,
    String? imageAsset,

  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      vietnameseName: vietnameseName ?? this.vietnameseName,
      description: description ?? this.description,
      exerciseType: exerciseType ?? this.exerciseType,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,

    );
  }

  @override
  String toString() {
    return 'ExerciseModel(id: $id, name: $name, vietnameseName: $vietnameseName, type: $exerciseType)';
  }
}
