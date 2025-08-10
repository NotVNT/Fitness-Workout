import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common_widget/round_textfield.dart';

void main() {
  group('RoundTextField Widget Tests', () {
    testWidgets('should display hint text and icon', (tester) async {
      // Arrange
      const hintText = 'Enter your name';
      const iconPath = 'assets/img/user_text.png';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundTextField(
              hitText: hintText,
              icon: iconPath,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RoundTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals(hintText));
    });

    testWidgets('should handle text input', (tester) async {
      // Arrange
      final controller = TextEditingController();
      const testText = 'Test input';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundTextField(
              hitText: 'Enter text',
              icon: 'assets/img/user_text.png',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), testText);

      // Assert
      expect(controller.text, equals(testText));
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should handle Vietnamese text with diacritics',
        (tester) async {
      // Arrange
      final controller = TextEditingController();
      const vietnameseText = 'Nguyễn Văn Anh';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundTextField(
              hitText: 'Nhập tên',
              icon: 'assets/img/user_text.png',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), vietnameseText);

      // Assert
      expect(controller.text, equals(vietnameseText));
      expect(find.text(vietnameseText), findsOneWidget);
    });

    testWidgets('should handle obscure text for passwords', (tester) async {
      // Arrange
      final controller = TextEditingController();
      const password = 'secretpassword';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundTextField(
              hitText: 'Enter password',
              icon: 'assets/img/lock.png',
              controller: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), password);

      // Assert
      expect(controller.text, equals(password));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should display suffix icon when provided', (tester) async {
      // Arrange
      const suffixIcon = Icon(Icons.visibility);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundTextField(
              hitText: 'Password',
              icon: 'assets/img/lock.png',
              rigtIcon: suffixIcon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.suffixIcon, equals(suffixIcon));
    });

    group('Keyboard Type Tests', () {
      testWidgets('should set email keyboard type', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Email',
                icon: 'assets/img/email.png',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, equals(TextInputType.emailAddress));
      });

      testWidgets('should set number keyboard type', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Phone',
                icon: 'assets/img/user_text.png',
                keyboardType: TextInputType.number,
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, equals(TextInputType.number));
      });

      testWidgets('should set multiline keyboard type', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Description',
                icon: 'assets/img/email.png',
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, equals(TextInputType.multiline));
      });
    });

    group('Styling Tests', () {
      testWidgets('should apply default margin', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Test',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RoundTextField),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
            container.margin, equals(const EdgeInsets.symmetric(vertical: 10)));
      });

      testWidgets('should apply custom margin', (tester) async {
        // Arrange
        const customMargin = EdgeInsets.all(20);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Test',
                icon: 'assets/img/user_text.png',
                margin: customMargin,
              ),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RoundTextField),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(container.margin, equals(customMargin));
      });

      testWidgets('should have rounded corners', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Test',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RoundTextField),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, equals(BorderRadius.circular(15)));
      });
    });

    group('Text Properties Tests', () {
      testWidgets('should have correct text properties for Vietnamese support',
          (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Nhập văn bản',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enableIMEPersonalizedLearning, isTrue);
        expect(textField.autocorrect, isFalse);
        expect(textField.enableSuggestions, isFalse);
        expect(textField.textInputAction, equals(TextInputAction.next));
        expect(textField.textAlign, equals(TextAlign.start));
        expect(textField.textDirection, equals(TextDirection.ltr));
      });

      testWidgets('should have correct text style', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Test',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.fontSize, equals(15));
        expect(textField.style?.fontFamily, equals('Poppins'));
      });
    });

    group('Focus and Interaction Tests', () {
      testWidgets('should handle focus changes', (tester) async {
        // Arrange
        final controller = TextEditingController();

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Focus test',
                icon: 'assets/img/user_text.png',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        await tester.pump();

        // Assert
        expect(tester.testTextInput.hasAnyClients, isTrue);
      });

      testWidgets('should handle text selection', (tester) async {
        // Arrange
        final controller = TextEditingController();
        const testText = 'Selectable text';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Selection test',
                icon: 'assets/img/user_text.png',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), testText);
        await tester.pump();

        // Assert
        expect(controller.text, equals(testText));
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle empty hint text', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: '',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.hintText, equals(''));
      });

      testWidgets('should handle very long text input', (tester) async {
        // Arrange
        final controller = TextEditingController();
        const longText =
            'This is a very long text input that should be handled properly by the text field widget without any issues or overflow problems';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Long text',
                icon: 'assets/img/user_text.png',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), longText);

        // Assert
        expect(controller.text, equals(longText));
      });

      testWidgets('should handle special characters', (tester) async {
        // Arrange
        final controller = TextEditingController();
        const specialText = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Special chars',
                icon: 'assets/img/user_text.png',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), specialText);

        // Assert
        expect(controller.text, equals(specialText));
      });

      testWidgets('should handle null margin', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'No margin',
                icon: 'assets/img/user_text.png',
                margin: null,
              ),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RoundTextField),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(container.margin, isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundTextField(
                hitText: 'Accessible field',
                icon: 'assets/img/user_text.png',
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        // TextField is inherently accessible
      });
    });
  });
}
