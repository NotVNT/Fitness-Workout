import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness/common/colo_extension.dart';

void main() {
  group('TColor Tests', () {
    group('Primary Colors Tests', () {
      test('should return correct primary color 1', () {
        expect(TColor.primaryColor1, equals(const Color(0xff92A3FD)));
      });

      test('should return correct primary color 2', () {
        expect(TColor.primaryColor2, equals(const Color(0xff9DCEFF)));
      });

      test('should return correct primary gradient', () {
        final gradient = TColor.primaryG;
        expect(gradient.length, equals(2));
        expect(gradient[0], equals(TColor.primaryColor2));
        expect(gradient[1], equals(TColor.primaryColor1));
      });
    });

    group('Secondary Colors Tests', () {
      test('should return correct secondary color 1', () {
        expect(TColor.secondaryColor1, equals(const Color(0xffC58BF2)));
      });

      test('should return correct secondary color 2', () {
        expect(TColor.secondaryColor2, equals(const Color(0xffEEA4CE)));
      });

      test('should return correct secondary gradient', () {
        final gradient = TColor.secondaryG;
        expect(gradient.length, equals(2));
        expect(gradient[0], equals(TColor.secondaryColor2));
        expect(gradient[1], equals(TColor.secondaryColor1));
      });
    });

    group('Basic Colors Tests', () {
      test('should return correct black color', () {
        expect(TColor.black, equals(const Color(0xff1D1617)));
      });

      test('should return correct gray color', () {
        expect(TColor.gray, equals(const Color(0xff786F72)));
      });

      test('should return correct white color', () {
        expect(TColor.white, equals(Colors.white));
      });

      test('should return correct light gray color', () {
        expect(TColor.lightGray, equals(const Color(0xffF7F8F8)));
      });
    });

    group('Color Consistency Tests', () {
      test('should maintain consistent color values across calls', () {
        // Test that colors are consistent across multiple calls
        final color1First = TColor.primaryColor1;
        final color1Second = TColor.primaryColor1;
        expect(color1First, equals(color1Second));

        final gradientFirst = TColor.primaryG;
        final gradientSecond = TColor.primaryG;
        expect(gradientFirst[0], equals(gradientSecond[0]));
        expect(gradientFirst[1], equals(gradientSecond[1]));
      });

      test('should have different primary and secondary colors', () {
        expect(TColor.primaryColor1, isNot(equals(TColor.secondaryColor1)));
        expect(TColor.primaryColor2, isNot(equals(TColor.secondaryColor2)));
      });

      test('should have different gradient colors within each gradient', () {
        expect(TColor.primaryColor1, isNot(equals(TColor.primaryColor2)));
        expect(TColor.secondaryColor1, isNot(equals(TColor.secondaryColor2)));
      });
    });

    group('Color Properties Tests', () {
      test('should have valid alpha values', () {
        expect(TColor.primaryColor1.alpha, greaterThan(0));
        expect(TColor.primaryColor2.alpha, greaterThan(0));
        expect(TColor.secondaryColor1.alpha, greaterThan(0));
        expect(TColor.secondaryColor2.alpha, greaterThan(0));
        expect(TColor.black.alpha, greaterThan(0));
        expect(TColor.gray.alpha, greaterThan(0));
        expect(TColor.white.alpha, greaterThan(0));
        expect(TColor.lightGray.alpha, greaterThan(0));
      });

      test('should have valid RGB values', () {
        // Test that RGB values are within valid range (0-255)
        void testColorRGB(Color color) {
          expect(color.red, inInclusiveRange(0, 255));
          expect(color.green, inInclusiveRange(0, 255));
          expect(color.blue, inInclusiveRange(0, 255));
        }

        testColorRGB(TColor.primaryColor1);
        testColorRGB(TColor.primaryColor2);
        testColorRGB(TColor.secondaryColor1);
        testColorRGB(TColor.secondaryColor2);
        testColorRGB(TColor.black);
        testColorRGB(TColor.gray);
        testColorRGB(TColor.white);
        testColorRGB(TColor.lightGray);
      });
    });

    group('Gradient Tests', () {
      test('should create gradients with correct order', () {
        final primaryGradient = TColor.primaryG;
        final secondaryGradient = TColor.secondaryG;

        // Primary gradient: [primaryColor2, primaryColor1]
        expect(primaryGradient[0], equals(TColor.primaryColor2));
        expect(primaryGradient[1], equals(TColor.primaryColor1));

        // Secondary gradient: [secondaryColor2, secondaryColor1]
        expect(secondaryGradient[0], equals(TColor.secondaryColor2));
        expect(secondaryGradient[1], equals(TColor.secondaryColor1));
      });

      test('should create new list instances for gradients', () {
        final gradient1 = TColor.primaryG;
        final gradient2 = TColor.primaryG;

        // Should be equal in content but different instances
        expect(gradient1, equals(gradient2));
        expect(identical(gradient1, gradient2), isFalse);
      });
    });
  });

  group('ColorExtension Tests', () {
    group('withOpacityValue Method Tests', () {
      test('should create color with specified opacity', () {
        const baseColor = Color(0xFFFF0000); // Red
        final colorWithOpacity = baseColor.withOpacityValue(0.5);

        expect(colorWithOpacity.r, equals(baseColor.r));
        expect(colorWithOpacity.g, equals(baseColor.g));
        expect(colorWithOpacity.b, equals(baseColor.b));
        // Note: withValues(alpha: 0.5) sets alpha to 0.5
        expect(colorWithOpacity.a, equals(0.5));
      });

      test('should handle opacity value 0.0', () {
        const baseColor = Color(0xFF00FF00); // Green
        final transparentColor = baseColor.withOpacityValue(0.0);

        expect(transparentColor.a, equals(0.0));
        expect(transparentColor.r, equals(baseColor.r));
        expect(transparentColor.g, equals(baseColor.g));
        expect(transparentColor.b, equals(baseColor.b));
      });

      test('should handle opacity value 1.0', () {
        const baseColor = Color(0xFF0000FF); // Blue
        final opaqueColor = baseColor.withOpacityValue(1.0);

        expect(opaqueColor.a, equals(1.0));
        expect(opaqueColor.r, equals(baseColor.r));
        expect(opaqueColor.g, equals(baseColor.g));
        expect(opaqueColor.b, equals(baseColor.b));
      });

      test('should handle various opacity values', () {
        const baseColor = Color(0xFFFFFFFF); // White

        final opacity25 = baseColor.withOpacityValue(0.25);
        final opacity50 = baseColor.withOpacityValue(0.5);
        final opacity75 = baseColor.withOpacityValue(0.75);

        expect(opacity25.a, equals(0.25));
        expect(opacity50.a, equals(0.5));
        expect(opacity75.a, equals(0.75));
      });

      test('should work with TColor colors', () {
        final primaryWithOpacity = TColor.primaryColor1.withOpacityValue(0.7);
        final secondaryWithOpacity =
            TColor.secondaryColor1.withOpacityValue(0.3);

        expect(primaryWithOpacity.r, equals(TColor.primaryColor1.r));
        expect(primaryWithOpacity.g, equals(TColor.primaryColor1.g));
        expect(primaryWithOpacity.b, equals(TColor.primaryColor1.b));
        expect(primaryWithOpacity.a, equals(0.7));

        expect(secondaryWithOpacity.r, equals(TColor.secondaryColor1.r));
        expect(secondaryWithOpacity.g, equals(TColor.secondaryColor1.g));
        expect(secondaryWithOpacity.b, equals(TColor.secondaryColor1.b));
        expect(secondaryWithOpacity.a, equals(0.3));
      });

      test('should preserve original color when creating new opacity variant',
          () {
        final originalColor = TColor.primaryColor1;
        final originalAlpha = originalColor.a;

        final modifiedColor = originalColor.withOpacityValue(0.5);

        // Original color should remain unchanged
        expect(originalColor.a, equals(originalAlpha));
        expect(modifiedColor.a, isNot(equals(originalAlpha)));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle opacity values outside normal range', () {
        const baseColor = Color(0xFF123456);

        // Values outside 0.0-1.0 range might be clamped by the framework
        final negativeOpacity = baseColor.withOpacityValue(-0.5);
        final largeOpacity = baseColor.withOpacityValue(2.0);

        // The exact behavior depends on the framework implementation
        // but the method should not crash
        expect(negativeOpacity, isA<Color>());
        expect(largeOpacity, isA<Color>());
      });

      test('should work with colors that already have opacity', () {
        const semiTransparentColor = Color(0x80FF0000); // 50% transparent red
        final modifiedColor = semiTransparentColor.withOpacityValue(0.25);

        expect(modifiedColor.r, equals(semiTransparentColor.r));
        expect(modifiedColor.g, equals(semiTransparentColor.g));
        expect(modifiedColor.b, equals(semiTransparentColor.b));
        expect(modifiedColor.a, equals(0.25));
      });
    });
  });
}
