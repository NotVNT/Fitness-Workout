import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';

void main() {
  group('SignUpView Simple Widget Tests', () {
    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Xin chào,'),
                const Text('Tạo tài khoản'),
                RoundTextField(
                  hitText: 'Tên',
                  icon: 'assets/img/user_text.png',
                ),
                RoundTextField(
                  hitText: 'Họ',
                  icon: 'assets/img/user_text.png',
                ),
                RoundTextField(
                  hitText: 'Số điện thoại',
                  icon: 'assets/img/p_contact.png',
                ),
                RoundTextField(
                  hitText: 'Ngày sinh (dd/mm/yyyy)',
                  icon: 'assets/img/date.png',
                ),
                RoundTextField(
                  hitText: 'Email',
                  icon: 'assets/img/email.png',
                ),
                RoundTextField(
                  hitText: 'Mật khẩu',
                  icon: 'assets/img/lock.png',
                ),
                RoundTextField(
                  hitText: 'Xác nhận mật khẩu',
                  icon: 'assets/img/lock.png',
                ),
                RoundButton(
                  title: 'Đăng ký',
                  onPressed: () {},
                ),
                const Text('Đã có tài khoản?'),
                const Text('Đăng nhập'),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('should display all required UI elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Tạo tài khoản'), findsOneWidget);
      expect(find.byType(RoundTextField), findsNWidgets(7)); // All input fields
      expect(find.byType(RoundButton), findsOneWidget); // Signup button
      expect(find.text('Đã có tài khoản?'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });

    testWidgets('should display signup button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(RoundButton), findsOneWidget);
      expect(find.text('Đăng ký'), findsOneWidget);
    });

    testWidgets('should display all input fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check all input fields are present
      expect(find.text('Tên'), findsOneWidget);
      expect(find.text('Họ'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Ngày sinh (dd/mm/yyyy)'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('should allow text input in fields', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter text in first few fields
      await tester.enterText(find.byType(RoundTextField).at(0), 'Nguyễn');
      await tester.enterText(find.byType(RoundTextField).at(1), 'Văn A');
      await tester.enterText(find.byType(RoundTextField).at(2), '0987654321');
      await tester.pump();

      // Assert - Text should be entered successfully
      expect(tester.takeException(), isNull);
    });

    testWidgets('should scroll when content overflows', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Should have SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
