import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _workouts => _firestore.collection('workouts');
  CollectionReference get _userProgress =>
      _firestore.collection('user_progress');

  // User Profile Methods
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? phone,
    double? weight,
    double? height,
    double? targetWeight,
    String? goal,
  }) async {
    try {
      print(
          'FirestoreService: Tạo user profile cho userId: $userId, email: $email');
      Map<String, dynamic> userData = {
        'email': email,
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'dateOfBirth': dateOfBirth ?? '',
        'gender': gender ?? '',
        'phone': phone ?? '',
        'weight': weight ?? 0.0,
        'height': height ?? 0.0,
        'targetWeight': targetWeight ?? 0.0,
        'goal': goal ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _users.doc(userId).set(userData);
      print('FirestoreService: Tạo user profile thành công');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserProfile(String userId) async {
    try {
      print('FirestoreService: Đang lấy user profile cho userId: $userId');
      final doc = await _users.doc(userId).get();
      print('FirestoreService: Document exists: ${doc.exists}');
      if (doc.exists) {
        print('FirestoreService: Document data: ${doc.data()}');
      }
      return doc;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? phone,
    double? weight,
    double? height,
    double? targetWeight,
    String? goal,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (gender != null) updateData['gender'] = gender;
      if (phone != null) updateData['phone'] = phone;
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (targetWeight != null) updateData['targetWeight'] = targetWeight;
      if (goal != null) updateData['goal'] = goal;

      await _users.doc(userId).update(updateData);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Workout Methods
  Future<void> saveWorkoutSession({
    required String userId,
    required String workoutType,
    required int duration, // in minutes
    required int caloriesBurned,
    required DateTime date,
    Map<String, dynamic>? exercises,
  }) async {
    try {
      await _workouts.add({
        'userId': userId,
        'workoutType': workoutType,
        'duration': duration,
        'caloriesBurned': caloriesBurned,
        'date': Timestamp.fromDate(date),
        'exercises': exercises ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving workout session: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getUserWorkouts(String userId) async {
    try {
      return await _workouts
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
    } catch (e) {
      print('Error getting user workouts: $e');
      rethrow;
    }
  }

  // Progress Tracking Methods
  Future<void> saveUserProgress({
    required String userId,
    required DateTime date,
    double? weight,
    Map<String, dynamic>? measurements,
    String? notes,
  }) async {
    try {
      String progressId = '${userId}_${date.year}_${date.month}_${date.day}';

      await _userProgress.doc(progressId).set({
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'weight': weight,
        'measurements': measurements ?? {},
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user progress: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getUserProgress(String userId) async {
    try {
      return await _userProgress
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
    } catch (e) {
      print('Error getting user progress: $e');
      rethrow;
    }
  }

  // Stream methods for real-time updates
  Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    return _users.doc(userId).snapshots();
  }

  Stream<QuerySnapshot> getUserWorkoutsStream(String userId) {
    return _workouts
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Helper method to get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Clean up old user data (remove hashedPassword field)
  Future<void> cleanupOldUserData(String userId) async {
    try {
      print('FirestoreService: Cleaning up old data for userId: $userId');
      await _users.doc(userId).update({
        'hashedPassword': FieldValue.delete(),
      });
      print('FirestoreService: Cleaned up old data successfully');
    } catch (e) {
      print('Error cleaning up old user data: $e');
      // Don't rethrow - this is not critical
    }
  }

  // Delete user data (for account deletion)
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete user profile
      await _users.doc(userId).delete();

      // Delete user workouts
      QuerySnapshot workouts =
          await _workouts.where('userId', isEqualTo: userId).get();
      for (QueryDocumentSnapshot doc in workouts.docs) {
        await doc.reference.delete();
      }

      // Delete user progress
      QuerySnapshot progress =
          await _userProgress.where('userId', isEqualTo: userId).get();
      for (QueryDocumentSnapshot doc in progress.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}
