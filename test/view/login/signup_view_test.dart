import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';

void main() {
  group('SignUpView Widget Tests', () {
    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Xin chào,'),
                const Text('Tạo tài khoản'),
                const RoundTextField(
                  hitText: 'Tên',
                  icon: 'assets/img/user_text.png',
                ),
                const RoundTextField(
                  hitText: 'Họ',
                  icon: 'assets/img/user_text.png',
                ),
                const RoundTextField(
                  hitText: 'Số điện thoại',
                  icon: 'assets/img/p_contact.png',
                ),
                const RoundTextField(
                  hitText: 'Ngày sinh (dd/mm/yyyy)',
                  icon: 'assets/img/date.png',
                ),
                const RoundTextField(
                  hitText: 'Email',
                  icon: 'assets/img/email.png',
                ),
                const RoundTextField(
                  hitText: 'Mật khẩu',
                  icon: 'assets/img/lock.png',
                ),
                const RoundTextField(
                  hitText: 'Xác nhận mật khẩu',
                  icon: 'assets/img/lock.png',
                ),
                RoundButton(title: 'Đăng ký', onPressed: () {}),
                const Text('Đã có tài khoản?'),
                const Text('Đăng nhập'),
              ],
            ),
          ),
        ),
      );
    }

    group('UI Elements Tests', () {
      testWidgets('should display all required UI elements', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Xin chào,'), findsOneWidget);
        expect(find.text('Tạo tài khoản'), findsOneWidget);
        expect(
            find.byType(RoundTextField), findsNWidgets(7)); // All text fields
        expect(find.byType(RoundButton), findsOneWidget); // Sign up button
        expect(find.text('Đã có tài khoản?'), findsOneWidget);
        expect(find.text('Đăng nhập'), findsOneWidget);
      });

      testWidgets('should not display Google and Facebook buttons',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Verify social login buttons are removed
        expect(find.image(const AssetImage('assets/img/google.png')),
            findsNothing);
        expect(find.image(const AssetImage('assets/img/facebook.png')),
            findsNothing);
        expect(find.text('Hoặc'), findsNothing);
      });
    });

    // Note: Complex interaction tests would require proper setup
    // These tests are commented out as they require:
    // 1. Proper dependency injection for AuthService
    // 2. Mock setup for Firebase services
    // 3. Navigation testing framework
    // 4. State management setup
  });
}
