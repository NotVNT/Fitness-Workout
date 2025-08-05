import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final double weight;
  final double height;
  final double targetWeight;
  final String goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.weight = 0.0,
    this.height = 0.0,
    this.targetWeight = 0.0,
    this.goal = '',
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      height: (data['height'] ?? 0.0).toDouble(),
      targetWeight: (data['targetWeight'] ?? 0.0).toDouble(),
      goal: data['goal'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'weight': weight,
      'height': height,
      'targetWeight': targetWeight,
      'goal': goal,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Get full name
  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return 'User';
    return '$firstName $lastName'.trim();
  }

  // Get BMI
  double get bmi {
    if (height <= 0 || weight <= 0) return 0.0;
    double heightInMeters = height / 100; // Convert cm to meters
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    double bmiValue = bmi;
    if (bmiValue == 0.0) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Get age from date of birth
  int get age {
    if (dateOfBirth.isEmpty) return 0;
    try {
      DateTime birthDate = DateTime.parse(dateOfBirth);
      DateTime now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    double? targetWeight,
    String? goal,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      goal: goal ?? this.goal,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, weight: $weight, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
