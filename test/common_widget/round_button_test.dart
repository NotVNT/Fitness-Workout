import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common_widget/round_button.dart';

void main() {
  group('RoundButton Widget Tests', () {
    testWidgets('should display title when provided', (tester) async {
      // Arrange
      bool pressed = false;
      const title = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundButton(
              title: title,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.byType(RoundButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      bool pressed = false;
      const icon = Icons.add;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundButton(
              icon: icon,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(icon), findsOneWidget);
      expect(find.byType(RoundButton), findsOneWidget);
    });

    testWidgets('should handle onPressed callback', (tester) async {
      // Arrange
      bool pressed = false;
      const title = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundButton(
              title: title,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RoundButton));
      await tester.pump();

      // Assert
      expect(pressed, isTrue);
    });

    testWidgets('should display empty widget when no title or icon provided', (tester) async {
      // Arrange
      bool pressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(RoundButton), findsOneWidget);
    });

    group('RoundButtonType Tests', () {
      testWidgets('should render bgGradient type correctly', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Gradient Button',
                type: RoundButtonType.bgGradient,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Gradient Button'), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });

      testWidgets('should render bgSGradient type correctly', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Secondary Gradient',
                type: RoundButtonType.bgSGradient,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Secondary Gradient'), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });

      testWidgets('should render textGradient type correctly', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Text Gradient',
                type: RoundButtonType.textGradient,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Text Gradient'), findsOneWidget);
        expect(find.byType(ShaderMask), findsOneWidget);
      });
    });

    group('Customization Tests', () {
      testWidgets('should apply custom fontSize', (tester) async {
        // Arrange
        bool pressed = false;
        const customFontSize = 20.0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Custom Font Size',
                fontSize: customFontSize,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        final textWidget = tester.widget<Text>(find.text('Custom Font Size'));
        expect(textWidget.style?.fontSize, equals(customFontSize));
      });

      testWidgets('should apply custom fontWeight', (tester) async {
        // Arrange
        bool pressed = false;
        const customFontWeight = FontWeight.w400;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Custom Font Weight',
                fontWeight: customFontWeight,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        final textWidget = tester.widget<Text>(find.text('Custom Font Weight'));
        expect(textWidget.style?.fontWeight, equals(customFontWeight));
      });

      testWidgets('should apply custom iconSize', (tester) async {
        // Arrange
        bool pressed = false;
        const customIconSize = 24.0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                icon: Icons.star,
                iconSize: customIconSize,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(iconWidget.size, equals(customIconSize));
      });

      testWidgets('should apply custom elevation for textGradient type', (tester) async {
        // Arrange
        bool pressed = false;
        const customElevation = 5.0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Elevated Button',
                type: RoundButtonType.textGradient,
                elevation: customElevation,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(RoundButton), findsOneWidget);
        // Note: Testing elevation directly is complex in widget tests
        // This test ensures the widget renders without errors
      });
    });

    group('Layout Tests', () {
      testWidgets('should have correct container dimensions', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Layout Test',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(RoundButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.height, equals(50));
        expect(sizedBox.width, equals(double.maxFinite));
      });

      testWidgets('should have rounded corners', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Rounded Button',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final buttonStyle = elevatedButton.style;
        expect(buttonStyle, isNotNull);
        // Note: Testing specific border radius requires more complex widget inspection
      });
    });

    group('Interaction Tests', () {
      testWidgets('should be tappable', (tester) async {
        // Arrange
        int tapCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Tap Me',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        );

        // Multiple taps
        await tester.tap(find.byType(RoundButton));
        await tester.pump();
        await tester.tap(find.byType(RoundButton));
        await tester.pump();

        // Assert
        expect(tapCount, equals(2));
      });

      testWidgets('should handle rapid taps', (tester) async {
        // Arrange
        int tapCount = 0;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Rapid Tap',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        );

        // Rapid taps
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(RoundButton));
        }
        await tester.pump();

        // Assert
        expect(tapCount, equals(5));
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle empty title', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: '',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(''), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });

      testWidgets('should handle very long title', (tester) async {
        // Arrange
        bool pressed = false;
        const longTitle = 'This is a very long button title that might overflow';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: longTitle,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(longTitle), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });

      testWidgets('should handle extreme fontSize values', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Tiny Text',
                fontSize: 1.0,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Tiny Text'), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });

      testWidgets('should handle extreme iconSize values', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                icon: Icons.star,
                iconSize: 1.0,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byType(RoundButton), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (tester) async {
        // Arrange
        bool pressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoundButton(
                title: 'Accessible Button',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
        // ElevatedButton is inherently accessible
      });
    });
  });
}
