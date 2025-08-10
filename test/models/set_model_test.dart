import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/models/set_model.dart';

void main() {
  group('SetModel Tests', () {
    test('should create SetModel with required fields', () {
      // Arrange & Act
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
      );

      // Assert
      expect(set.id, equals('set1'));
      expect(set.setNumber, equals(1));
      expect(set.reps, equals(10));
      expect(set.weight, equals(20.5));
      expect(set.duration, isNull);
      expect(set.restTime, isNull);
      expect(set.isCompleted, isFalse);
    });

    test('should create SetModel with optional fields', () {
      // Arrange & Act
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
        duration: 60,
        restTime: 90,
        isCompleted: true,
      );

      // Assert
      expect(set.duration, equals(60));
      expect(set.restTime, equals(90));
      expect(set.isCompleted, isTrue);
    });

    test('should create SetModel from Map', () {
      // Arrange
      final data = {
        'setNumber': 2,
        'reps': 15,
        'weight': 25.0,
        'duration': 45,
        'restTime': 60,
        'isCompleted': true,
      };

      // Act
      final set = SetModel.fromMap(data, 'set2');

      // Assert
      expect(set.id, equals('set2'));
      expect(set.setNumber, equals(2));
      expect(set.reps, equals(15));
      expect(set.weight, equals(25.0));
      expect(set.duration, equals(45));
      expect(set.restTime, equals(60));
      expect(set.isCompleted, isTrue);
    });

    test('should handle missing fields when creating from Map', () {
      // Arrange
      final data = {
        'reps': 10,
        // Missing other fields
      };

      // Act
      final set = SetModel.fromMap(data, 'set1');

      // Assert
      expect(set.id, equals('set1'));
      expect(set.setNumber, equals(1)); // Default value
      expect(set.reps, equals(10));
      expect(set.weight, equals(0.0)); // Default value
      expect(set.duration, isNull);
      expect(set.restTime, isNull);
      expect(set.isCompleted, isFalse); // Default value
    });

    test('should convert SetModel to Map', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
        duration: 60,
        restTime: 90,
        isCompleted: true,
      );

      // Act
      final map = set.toMap();

      // Assert
      expect(map['setNumber'], equals(1));
      expect(map['reps'], equals(10));
      expect(map['weight'], equals(20.5));
      expect(map['duration'], equals(60));
      expect(map['restTime'], equals(90));
      expect(map['isCompleted'], isTrue);
      expect(map.containsKey('id'), isFalse); // ID not included in toMap
    });

    test('should copy SetModel with new values', () {
      // Arrange
      final original = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
      );

      // Act
      final copied = original.copyWith(
        reps: 15,
        weight: 25.0,
        isCompleted: true,
      );

      // Assert
      expect(copied.id, equals(original.id));
      expect(copied.setNumber, equals(original.setNumber));
      expect(copied.reps, equals(15));
      expect(copied.weight, equals(25.0));
      expect(copied.duration, equals(original.duration));
      expect(copied.restTime, equals(original.restTime));
      expect(copied.isCompleted, isTrue);
    });

    test('should format weight correctly', () {
      // Arrange
      final set1 = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.0,
      );

      final set2 = SetModel(
        id: 'set2',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
      );

      // Act & Assert
      expect(set1.formattedWeight, equals('20.0 kg'));
      expect(set2.formattedWeight, equals('20.5 kg'));
    });

    test('should calculate volume correctly', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.5,
      );

      // Act
      final volume = set.volume;

      // Assert
      expect(volume, equals(205.0)); // 10 * 20.5
    });

    test('should calculate volume with zero weight', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 0.0,
      );

      // Act
      final volume = set.volume;

      // Assert
      expect(volume, equals(0.0));
    });

    test('should calculate volume with zero reps', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 0,
        weight: 20.5,
      );

      // Act
      final volume = set.volume;

      // Assert
      expect(volume, equals(0.0));
    });

    test('should return correct toString representation', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 2,
        reps: 15,
        weight: 25.5,
        isCompleted: true,
      );

      // Act
      final stringRepresentation = set.toString();

      // Assert
      expect(stringRepresentation, contains('setNumber: 2'));
      expect(stringRepresentation, contains('reps: 15'));
      expect(stringRepresentation, contains('weight: 25.5kg'));
      expect(stringRepresentation, contains('completed: true'));
    });

    test('should handle duration-based sets', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 0, // No reps for duration-based
        weight: 0.0, // No weight for bodyweight
        duration: 60, // 60 seconds
        restTime: 30,
      );

      // Act & Assert
      expect(set.duration, equals(60));
      expect(set.reps, equals(0));
      expect(set.weight, equals(0.0));
      expect(set.volume, equals(0.0)); // Volume is 0 for duration-based
    });

    test('should handle rest time correctly', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.0,
        restTime: 120, // 2 minutes
      );

      // Act & Assert
      expect(set.restTime, equals(120));
    });

    test('should handle completion status changes', () {
      // Arrange
      final set = SetModel(
        id: 'set1',
        setNumber: 1,
        reps: 10,
        weight: 20.0,
        isCompleted: false,
      );

      // Act
      final completedSet = set.copyWith(isCompleted: true);

      // Assert
      expect(set.isCompleted, isFalse);
      expect(completedSet.isCompleted, isTrue);
    });
  });
}
