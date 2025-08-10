# 🧪 Fitness Workout App - Test Suite

## 📋 Tổng quan

Test suite này bao gồm các test toàn diện cho ứng dụng Fitness Workout, được tổ chức theo cấu trúc tương tự như thư mục `lib`.

## 📁 Cấu trúc Test

```
test/
├── services/                    # Test cho business logic
│   ├── auth_service_test.dart          # Test xác thực
│   └── workout_generator_service_test.dart  # Test tạo workout
├── view/                        # Test cho UI components
│   ├── login/
│   │   ├── login_view_test.dart        # Test màn hình đăng nhập
│   │   └── signup_view_test.dart       # Test màn hình đăng ký
│   ├── on_boarding/
│   │   └── on_boarding_view_test.dart  # Test onboarding
│   └── bmi_edit/
│       ├── bmi_calculator_test.dart    # Test tính BMI
│       ├── height_input_view_test.dart # Test nhập chiều cao
│       └── weight_input_view_test.dart # Test nhập cân nặng
├── test_runner.dart             # Test runner chính
└── README.md                    # Tài liệu này
```

## 🎯 Các loại Test

### 1. 🔐 Authentication Tests (`services/auth_service_test.dart`)
- **Sign Up Tests**: Đăng ký với thông tin hợp lệ/không hợp lệ
- **Sign In Tests**: Đăng nhập thành công/thất bại
- **Password Reset Tests**: Gửi email reset password
- **Validation Tests**: Kiểm tra email và password format
- **Error Handling Tests**: Xử lý các lỗi Firebase Auth

### 2. 🏋️ Workout Generator Tests (`services/workout_generator_service_test.dart`)
- **Goal Determination**: Xác định mục tiêu dựa trên BMI và target weight
- **Exercise Generation**: Tạo bài tập theo từng loại (cardio, strength, mixed)
- **Intensity Adjustment**: Điều chỉnh cường độ theo BMI
- **BMI Calculation**: Tính toán BMI chính xác
- **Performance Tests**: Kiểm tra hiệu suất tạo workout

### 3. 📱 UI Tests

#### Login View Tests (`view/login/login_view_test.dart`)
- **UI Elements**: Hiển thị đầy đủ các thành phần giao diện
- **Social Login Removal**: Xác nhận đã xóa Google/Facebook buttons
- **User Interaction**: Nhập liệu và tương tác
- **Validation**: Kiểm tra validation form
- **Authentication Flow**: Luồng đăng nhập

#### Signup View Tests (`view/login/signup_view_test.dart`)
- **Form Validation**: Kiểm tra tất cả trường bắt buộc
- **Terms Acceptance**: Đồng ý điều khoản sử dụng
- **Social Login Removal**: Xác nhận đã xóa social buttons
- **Navigation**: Chuyển đổi giữa các màn hình

#### Onboarding Tests (`view/on_boarding/on_boarding_view_test.dart`)
- **Page Navigation**: Chuyển trang bằng button và swipe
- **Content Display**: Hiển thị nội dung đúng cho từng trang
- **Animation**: Kiểm tra animation mượt mà
- **Accessibility**: Hỗ trợ screen reader và keyboard

### 4. 📊 BMI & Input Tests

#### BMI Calculator Tests (`view/bmi_edit/bmi_calculator_test.dart`)
- **BMI Calculation**: Công thức tính BMI chính xác
- **Category Classification**: Phân loại BMI (thiếu cân, bình thường, thừa cân, béo phì)
- **Recommendations**: Đưa ra khuyến nghị phù hợp
- **Edge Cases**: Xử lý các trường hợp biên
- **Progress Tracking**: Theo dõi thay đổi BMI

#### Height Input Tests (`view/bmi_edit/height_input_view_test.dart`)
- **Height Selection**: Chọn chiều cao bằng drag gesture
- **Range Validation**: Giới hạn chiều cao hợp lệ (100-220cm)
- **Animation**: Hiệu ứng chuyển động mượt mà
- **Accessibility**: Hỗ trợ keyboard navigation

#### Weight Input Tests (`view/bmi_edit/weight_input_view_test.dart`)
- **Weight Selection**: Chọn cân nặng với độ chính xác cao
- **Decimal Support**: Hỗ trợ số thập phân
- **Range Validation**: Giới hạn cân nặng hợp lệ (30-200kg)
- **Performance**: Xử lý thay đổi nhanh hiệu quả

## 🚀 Chạy Tests

### Chạy tất cả tests:
```bash
flutter test
```

### Chạy test cụ thể:
```bash
flutter test test/services/auth_service_test.dart
flutter test test/view/login/login_view_test.dart
```

### Chạy test với coverage:
```bash
flutter test --coverage
```

### Chạy test runner:
```bash
flutter test test/test_runner.dart
```

## 📊 Test Coverage

Mục tiêu coverage cho từng module:

- **Services**: ≥ 90% (business logic quan trọng)
- **Models**: ≥ 85% (data validation)
- **Views**: ≥ 75% (UI interactions)
- **Utilities**: ≥ 95% (helper functions)

## 🛠️ Test Utilities

### TestUtils Class
Cung cấp các helper methods:
- `createTestUser()`: Tạo user data test
- `createTestWorkout()`: Tạo workout data test
- `calculateBMI()`: Tính BMI
- `isValidEmail()`: Validate email
- `waitForAnimations()`: Đợi animation hoàn thành

### TestConstants Class
Định nghĩa các hằng số test:
- Default values cho user data
- BMI ranges và validation limits
- Error messages
- Timeouts

### TestMatchers Class
Custom matchers cho assertions:
- `isValidEmail`: Kiểm tra email hợp lệ
- `isValidPassword`: Kiểm tra password mạnh
- `isValidBMI`: Kiểm tra BMI trong phạm vi hợp lệ

## 🔧 Setup Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 📝 Viết Test Mới

### 1. Tạo file test:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Feature Tests', () {
    setUp(() {
      // Setup code
    });

    test('should do something', () {
      // Arrange
      // Act  
      // Assert
    });
  });
}
```

### 2. Widget test pattern:
```dart
testWidgets('should display widget correctly', (tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget());

  // Act
  await tester.tap(find.byType(Button));
  await tester.pump();

  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### 3. Mock services:
```dart
@GenerateMocks([AuthService])
import 'test_file.mocks.dart';

// In test:
when(mockAuthService.signIn(any, any))
    .thenAnswer((_) async => mockUserCredential);
```

## 🐛 Debugging Tests

### Chạy test với debug info:
```bash
flutter test --verbose
```

### Test specific widget:
```bash
flutter test --name "widget name"
```

### Test với breakpoints:
```bash
flutter test --start-paused
```

## 📈 Best Practices

1. **AAA Pattern**: Arrange, Act, Assert
2. **Descriptive Names**: Test names mô tả rõ ràng
3. **Single Responsibility**: Mỗi test chỉ test một chức năng
4. **Mock External Dependencies**: Mock Firebase, API calls
5. **Test Edge Cases**: Kiểm tra boundary conditions
6. **Clean Setup/Teardown**: Dọn dẹp sau mỗi test

## 🔄 CI/CD Integration

Tests sẽ được chạy tự động trong CI/CD pipeline:

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: flutter test --coverage
  
- name: Upload coverage
  uses: codecov/codecov-action@v3
```

## 📞 Support

Nếu có vấn đề với tests:
1. Kiểm tra dependencies trong pubspec.yaml
2. Chạy `flutter pub get`
3. Xem logs chi tiết với `--verbose`
4. Kiểm tra mock setup đúng chưa
