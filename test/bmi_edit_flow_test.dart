import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness/view/bmi_edit/height_input_view.dart';
import 'package:fitness/view/bmi_edit/current_weight_input_view.dart';
import 'package:fitness/view/bmi_edit/target_weight_input_view.dart';
import 'package:fitness/view/bmi_edit/creating_schedule_view.dart';
import 'package:fitness/providers/user_provider.dart';
import 'package:fitness/models/user_model.dart';

void main() {
  group('BMI Edit Flow Tests', () {
    late UserProvider mockUserProvider;

    setUp(() {
      mockUserProvider = UserProvider();
    });

    testWidgets('HeightInputView should display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const HeightInputView(),
          ),
        ),
      );

      // Verify the title is displayed
      expect(find.text('Chiều cao của bạn là bao nhiêu?'), findsOneWidget);

      // Verify the subtitle is displayed
      expect(
          find.text(
              'Điều này giúp chúng tôi tạo ra kế hoạch cá nhân hóa cho bạn'),
          findsOneWidget);

      // Verify the input field is present
      expect(find.byType(TextFormField), findsOneWidget);

      // Verify the next button is present
      expect(find.text('Tiếp theo'), findsOneWidget);
    });

    testWidgets('HeightInputView should validate input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const HeightInputView(),
          ),
        ),
      );

      // Try to submit without entering height
      await tester.tap(find.text('Tiếp theo'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Vui lòng nhập chiều cao'), findsOneWidget);

      // Enter invalid height
      await tester.enterText(find.byType(TextFormField), '400');
      await tester.tap(find.text('Tiếp theo'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Chiều cao không hợp lệ (1-300 cm)'), findsOneWidget);

      // Enter valid height
      await tester.enterText(find.byType(TextFormField), '170');
      await tester.tap(find.text('Tiếp theo'));
      await tester.pumpAndSettle();

      // Should navigate to next screen
      expect(find.byType(CurrentWeightInputView), findsOneWidget);
    });

    testWidgets('CurrentWeightInputView should display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const CurrentWeightInputView(height: 170),
          ),
        ),
      );

      // Verify the title is displayed
      expect(
          find.text('Cân nặng hiện tại của bạn là bao nhiêu?'), findsOneWidget);

      // Verify the input field is present
      expect(find.byType(TextFormField), findsOneWidget);

      // Verify the next button is present
      expect(find.text('Tiếp theo'), findsOneWidget);
    });

    testWidgets('TargetWeightInputView should display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const TargetWeightInputView(height: 170, currentWeight: 70),
          ),
        ),
      );

      // Verify the title is displayed
      expect(
          find.text('Cân nặng mục tiêu của bạn là bao nhiêu?'), findsOneWidget);

      // Verify the input field is present
      expect(find.byType(TextFormField), findsOneWidget);

      // Verify the next button is present
      expect(find.text('Tiếp theo'), findsOneWidget);
    });

    testWidgets('CreatingScheduleView should display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: mockUserProvider,
            child: const CreatingScheduleView(
              height: 170,
              currentWeight: 70,
              targetWeight: 65,
            ),
          ),
        ),
      );

      // Verify the loading title is displayed
      expect(find.text('Đang tạo lịch biểu hằng ngày của bạn'), findsOneWidget);

      // Verify the loading subtitle is displayed
      expect(find.text('Vui lòng đợi trong giây lát...'), findsOneWidget);
    });
  });
}
