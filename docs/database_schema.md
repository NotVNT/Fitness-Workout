# Database Schema - Fitness App

## Tổng Quan

Ứng dụng Fitness sử dụng **Cloud Firestore** với 4 model chính:
- **User** - Thông tin người dùng
- **Exercise** - Thư viện bài tập
- **Workout** - Buổi tập luyện
- **Set** - Chi tiết từng set trong bài tập

## 1. User Model

**Collection:** `users`  
**Document ID:** Sequential ID (1, 2, 3...) hoặc Firebase UID

```dart
{
  'email': 'user@example.com',
  'firstName': 'Nguyễn',
  'lastName': 'Văn A',
  'dateOfBirth': '1990-01-01',
  'gender': 'male', // 'male', 'female', 'other'
  'weight': 70.0, // kg
  'height': 170.0, // cm
  'targetWeight': 65.0, // kg
  'goal': 'lose_weight', // 'lose_weight', 'gain_muscle', 'maintain'
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**Computed Properties:**
- `fullName` - Họ tên đầy đủ
- `bmi` - Chỉ số BMI
- `bmiCategory` - Phân loại BMI
- `age` - Tuổi từ ngày sinh

## 2. Exercise Model

**Collection:** `exercises`  
**Document ID:** Auto-generated

```dart
{
  'name': 'Push-up',
  'vietnameseName': 'Chống đẩy',
  'description': 'Bài tập tăng cường sức mạnh tay và ngực',
  'category': 'strength', // 'cardio', 'strength', 'core', 'flexibility'
  'difficulty': 'beginner', // 'beginner', 'intermediate', 'advanced'
  'imageUrl': 'https://example.com/pushup.jpg',
  'videoUrl': 'https://example.com/pushup.mp4',
  'muscleGroups': ['chest', 'triceps', 'shoulders'],
  'instructions': {
    'setup': 'Nằm sấp, tay đặt rộng bằng vai',
    'execution': 'Đẩy người lên xuống',
    'tips': 'Giữ thẳng lưng'
  },
  'duration': null, // seconds (for time-based exercises)
  'defaultReps': 10,
  'defaultSets': 3,
  'defaultWeight': 0.0, // bodyweight exercise
  'isActive': true,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

## 3. Set Model

**Embedded trong WorkoutExercise**

```dart
{
  'setNumber': 1, // Set thứ mấy
  'reps': 10, // Số lần lặp lại
  'weight': 20.0, // Trọng lượng
  'weightUnit': 'kg', // 'kg' hoặc 'lbs'
  'duration': null, // Thời gian (giây) cho bài tập thời gian
  'restTime': 60, // Thời gian nghỉ (giây)
  'isCompleted': false,
  'notes': 'Cảm thấy khó ở set cuối',
  'completedAt': Timestamp,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**Computed Properties:**
- `weightInKg` - Chuyển đổi sang kg
- `weightInLbs` - Chuyển đổi sang lbs
- `formattedWeight` - Chuỗi hiển thị trọng lượng
- `volume` - Tổng volume (weight × reps)

## 4. Workout Model

**Collection:** `workouts`  
**Document ID:** Auto-generated

```dart
{
  'userId': '1', // ID của user
  'name': 'Push Day Workout',
  'description': 'Tập ngực, vai, tay sau',
  'exercises': [
    {
      'exerciseId': 'exercise_123',
      'sets': [
        {
          'setNumber': 1,
          'reps': 10,
          'weight': 20.0,
          'weightUnit': 'kg',
          'isCompleted': true,
          'completedAt': Timestamp
        },
        {
          'setNumber': 2,
          'reps': 8,
          'weight': 22.5,
          'weightUnit': 'kg',
          'isCompleted': false
        }
      ],
      'notes': 'Tăng trọng lượng từ tuần trước',
      'order': 1
    }
  ],
  'startTime': Timestamp,
  'endTime': Timestamp,
  'duration': 45, // phút
  'status': 'completed', // 'planned', 'in_progress', 'completed', 'cancelled'
  'workoutType': 'strength',
  'caloriesBurned': 250,
  'notes': 'Workout tốt hôm nay',
  'metadata': {
    'location': 'gym',
    'weather': 'sunny'
  },
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**Computed Properties:**
- `totalExercises` - Tổng số bài tập
- `completedExercises` - Số bài tập đã hoàn thành
- `totalSets` - Tổng số set
- `completedSets` - Số set đã hoàn thành
- `totalVolume` - Tổng volume của workout
- `progressPercentage` - Phần trăm hoàn thành

## Mối Quan Hệ

```
User (1) -----> (n) Workout
Workout (1) --> (n) WorkoutExercise
WorkoutExercise (1) --> (n) Set
WorkoutExercise (n) --> (1) Exercise
```

## Firestore Collections

1. **`users`** - Thông tin người dùng
2. **`exercises`** - Thư viện bài tập (shared data)
3. **`workouts`** - Buổi tập của từng user
4. **`counters`** - Counter cho sequential user ID
5. **`uid_mapping`** - Mapping Firebase UID → Sequential ID

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Everyone can read exercises
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Admin only in production
    }
    
    // Users can read/write their own workouts
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // Counter and mapping collections
    match /counters/{counterId} {
      allow read, write: if request.auth != null;
    }
    
    match /uid_mapping/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Ví Dụ Queries

### Lấy workouts của user
```dart
FirebaseFirestore.instance
  .collection('workouts')
  .where('userId', isEqualTo: currentUserId)
  .orderBy('startTime', descending: true)
  .limit(10)
```

### Lấy exercises theo category
```dart
FirebaseFirestore.instance
  .collection('exercises')
  .where('category', isEqualTo: 'strength')
  .where('isActive', isEqualTo: true)
```

### Lấy workouts trong khoảng thời gian
```dart
FirebaseFirestore.instance
  .collection('workouts')
  .where('userId', isEqualTo: currentUserId)
  .where('startTime', isGreaterThanOrEqualTo: startDate)
  .where('startTime', isLessThanOrEqualTo: endDate)
```

## Indexing

Firestore sẽ tự động tạo index cho:
- Single field queries
- Composite indexes cần tạo thủ công cho complex queries

**Composite Indexes cần thiết:**
1. `workouts`: `userId` + `startTime`
2. `exercises`: `category` + `isActive`
3. `exercises`: `difficulty` + `isActive`
