import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String vietnameseName;
  final String description;
  final String exerciseType; // 'reps' hoặc 'duration'
  final String? imageUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.description,
    required this.exerciseType,
    this.imageUrl,
  });

  // Factory constructor from Firestore
  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ExerciseModel(
      id: doc.id,
      name: data['name'] ?? '',
      vietnameseName: data['vietnameseName'] ?? '',
      description: data['description'] ?? '',
      exerciseType: data['exerciseType'] ?? 'reps',
      imageUrl: data['imageUrl'],
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
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      vietnameseName: vietnameseName ?? this.vietnameseName,
      description: description ?? this.description,
      exerciseType: exerciseType ?? this.exerciseType,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'ExerciseModel(id: $id, name: $name, vietnameseName: $vietnameseName, type: $exerciseType)';
  }
}
