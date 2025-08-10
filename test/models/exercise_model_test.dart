import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/exercise_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('ExerciseModel Tests', () {
    test('should create ExerciseModel with required fields', () {
      // Arrange & Act
      final exercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up exercise',
        exerciseType: 'reps',
      );

      // Assert
      expect(exercise.id, equals('ex1'));
      expect(exercise.name, equals('Push Up'));
      expect(exercise.vietnameseName, equals('Hít đất'));
      expect(exercise.description, equals('Basic push up exercise'));
      expect(exercise.exerciseType, equals('reps'));
      expect(exercise.imageUrl, isNull);
      expect(exercise.imageAsset, isNull);
    });

    test('should create ExerciseModel with optional fields', () {
      // Arrange & Act
      final exercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up exercise',
        exerciseType: 'reps',
        imageUrl: 'https://example.com/image.jpg',
        imageAsset: 'assets/img/pushup.png',
      );

      // Assert
      expect(exercise.imageUrl, equals('https://example.com/image.jpg'));
      expect(exercise.imageAsset, equals('assets/img/pushup.png'));
    });

    test('should create ExerciseModel from Firestore document', () {
      // Arrange
      final fakeFirestore = FakeFirebaseFirestore();
      final data = {
        'id': 'ex1',
        'name': 'Push Up',
        'vietnameseName': 'Hít đất',
        'description': 'Basic push up exercise',
        'exerciseType': 'reps',
        'imageUrl': 'https://example.com/image.jpg',
        'imageAsset': 'assets/img/pushup.png',
      };

      // Create a mock document
      final doc = MockDocumentSnapshot('ex1', data);

      // Act
      final exercise = ExerciseModel.fromFirestore(doc);

      // Assert
      expect(exercise.id, equals('ex1'));
      expect(exercise.name, equals('Push Up'));
      expect(exercise.vietnameseName, equals('Hít đất'));
      expect(exercise.description, equals('Basic push up exercise'));
      expect(exercise.exerciseType, equals('reps'));
      expect(exercise.imageUrl, equals('https://example.com/image.jpg'));
      expect(exercise.imageAsset, equals('assets/img/pushup.png'));
    });

    test('should handle missing fields when creating from Firestore', () {
      // Arrange
      final data = {
        'name': 'Push Up',
        // Missing other fields
      };

      final doc = MockDocumentSnapshot('ex1', data);

      // Act
      final exercise = ExerciseModel.fromFirestore(doc);

      // Assert
      expect(exercise.id, equals('ex1')); // Falls back to doc.id
      expect(exercise.name, equals('Push Up'));
      expect(exercise.vietnameseName, equals(''));
      expect(exercise.description, equals(''));
      expect(exercise.exerciseType, equals('reps')); // Default value
      expect(exercise.imageUrl, isNull);
      expect(exercise.imageAsset, isNull);
    });

    test('should sanitize imageAsset with quotes', () {
      // Arrange
      final data = {
        'name': 'Push Up',
        'imageAsset': '"assets/img/pushup.png"', // With quotes
      };

      final doc = MockDocumentSnapshot('ex1', data);

      // Act
      final exercise = ExerciseModel.fromFirestore(doc);

      // Assert
      expect(exercise.imageAsset, equals('assets/img/pushup.png')); // Quotes removed
    });

    test('should convert ExerciseModel to Map', () {
      // Arrange
      final exercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up exercise',
        exerciseType: 'reps',
        imageUrl: 'https://example.com/image.jpg',
        imageAsset: 'assets/img/pushup.png',
      );

      // Act
      final map = exercise.toMap();

      // Assert
      expect(map['name'], equals('Push Up'));
      expect(map['vietnameseName'], equals('Hít đất'));
      expect(map['description'], equals('Basic push up exercise'));
      expect(map['exerciseType'], equals('reps'));
      expect(map['imageUrl'], equals('https://example.com/image.jpg'));
      expect(map['imageAsset'], equals('assets/img/pushup.png'));
      expect(map.containsKey('id'), isFalse); // ID not included in toMap
    });

    test('should copy ExerciseModel with new values', () {
      // Arrange
      final original = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up exercise',
        exerciseType: 'reps',
      );

      // Act
      final copied = original.copyWith(
        name: 'Modified Push Up',
        exerciseType: 'duration',
        imageAsset: 'assets/img/new_pushup.png',
      );

      // Assert
      expect(copied.id, equals(original.id));
      expect(copied.name, equals('Modified Push Up'));
      expect(copied.vietnameseName, equals(original.vietnameseName));
      expect(copied.description, equals(original.description));
      expect(copied.exerciseType, equals('duration'));
      expect(copied.imageAsset, equals('assets/img/new_pushup.png'));
    });

    test('should return correct toString representation', () {
      // Arrange
      final exercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Basic push up exercise',
        exerciseType: 'reps',
      );

      // Act
      final stringRepresentation = exercise.toString();

      // Assert
      expect(stringRepresentation, contains('ex1'));
      expect(stringRepresentation, contains('Push Up'));
      expect(stringRepresentation, contains('Hít đất'));
      expect(stringRepresentation, contains('reps'));
    });

    test('should handle different exercise types', () {
      // Arrange & Act
      final repsExercise = ExerciseModel(
        id: 'ex1',
        name: 'Push Up',
        vietnameseName: 'Hít đất',
        description: 'Reps-based exercise',
        exerciseType: 'reps',
      );

      final durationExercise = ExerciseModel(
        id: 'ex2',
        name: 'Plank',
        vietnameseName: 'Plank',
        description: 'Duration-based exercise',
        exerciseType: 'duration',
      );

      // Assert
      expect(repsExercise.exerciseType, equals('reps'));
      expect(durationExercise.exerciseType, equals('duration'));
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
