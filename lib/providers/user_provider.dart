import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get BMI value
  double get bmi => _user?.bmi ?? 0.0;

  // Get BMI category
  String get bmiCategory => _user?.bmiCategory ?? 'Unknown';

  // Load user data from Firestore
  Future<void> loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _setLoading(true);
    try {
      final userDoc = await _firestoreService.getUserProfile(currentUser.uid);
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _user = UserModel(
          id: currentUser.uid,
          email: userData['email'] ?? currentUser.email ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          dateOfBirth: userData['dateOfBirth'] ?? '',
          gender: userData['gender'] ?? '',
          weight: (userData['weight'] ?? 0.0).toDouble(),
          height: (userData['height'] ?? 0.0).toDouble(),
          targetWeight: (userData['targetWeight'] ?? 0.0).toDouble(),
          goal: userData['goal'] ?? '',
        );
      } else {
        // Create default user if no data exists
        _user = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? '',
        );
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: $e';
      print('UserProvider: Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user weight and height
  Future<bool> updateWeightAndHeight({
    required double weight,
    required double height,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      // Update local user model
      _user = _user!.copyWith(
        weight: weight,
        height: height,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestoreService.updateUserProfile(
        userId: _user!.id,
        weight: weight,
        height: height,
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update weight and height: $e';
      print('UserProvider: Error updating weight and height: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user weight, height and target weight
  Future<bool> updateWeightHeightAndTarget({
    required double weight,
    required double height,
    required double targetWeight,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      // Update local user model
      _user = _user!.copyWith(
        weight: weight,
        height: height,
        targetWeight: targetWeight,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestoreService.updateUserProfile(
        userId: _user!.id,
        weight: weight,
        height: height,
        targetWeight: targetWeight,
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update weight, height and target weight: $e';
      print(
          'UserProvider: Error updating weight, height and target weight: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    String? goal,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    try {
      // Update local user model
      _user = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        weight: weight,
        height: height,
        goal: goal,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestoreService.updateUserProfile(
        userId: _user!.id,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        weight: weight,
        height: height,
        goal: goal,
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update user profile: $e';
      print('UserProvider: Error updating user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear user data (for logout)
  void clearUser() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get BMI status message based on BMI value
  String getBMIStatusMessage() {
    if (_user == null || _user!.weight <= 0 || _user!.height <= 0) {
      return 'Chưa có thông tin BMI';
    }

    double bmiValue = _user!.bmi;
    if (bmiValue < 18.5) {
      return 'Bạn đang thiếu cân';
    } else if (bmiValue < 25) {
      return 'Bạn có cân nặng bình thường';
    } else if (bmiValue < 30) {
      return 'Bạn đang thừa cân';
    } else {
      return 'Bạn đang béo phì';
    }
  }

  // Get BMI color based on BMI value
  Color getBMIColor() {
    if (_user == null || _user!.weight <= 0 || _user!.height <= 0) {
      return Colors.grey;
    }

    double bmiValue = _user!.bmi;
    if (bmiValue < 18.5) {
      return Colors.blue; // Underweight
    } else if (bmiValue < 25) {
      return Colors.green; // Normal
    } else if (bmiValue < 30) {
      return Colors.orange; // Overweight
    } else {
      return Colors.red; // Obese
    }
  }
}
