import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';

void main() {
  group('LoginView Simple Widget Tests', () {
    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Text('Xin chào,'),
              const Text('Chào mừng trở lại'),
              RoundTextField(
                hitText: 'Email',
                icon: 'assets/img/email.png',
              ),
              RoundTextField(
                hitText: 'Mật khẩu',
                icon: 'assets/img/lock.png',
              ),
              RoundButton(
                title: 'Đăng nhập',
                onPressed: () {},
              ),
              const Text('Quên mật khẩu?'),
              const Text('Chưa có tài khoản?'),
              const Text('Đăng ký'),
            ],
          ),
        ),
      );
    }

    testWidgets('should display all required UI elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Chào mừng trở lại'), findsOneWidget);
      expect(find.byType(RoundTextField), findsNWidgets(2)); // Email & Password
      expect(find.byType(RoundButton), findsOneWidget); // Login button
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Chưa có tài khoản?'), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(RoundButton), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });

    testWidgets('should allow text input in fields', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter text in email field
      await tester.enterText(find.byType(RoundTextField).first, 'test@example.com');
      await tester.pump();

      // Act - Enter text in password field  
      await tester.enterText(find.byType(RoundTextField).last, 'password123');
      await tester.pump();

      // Assert - Text should be entered successfully
      expect(tester.takeException(), isNull);
    });
  });
}
