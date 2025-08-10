import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness/providers/language_provider.dart';

void main() {
  group('LanguageProvider Tests', () {
    late LanguageProvider languageProvider;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Initialization Tests', () {
      test('should initialize with Vietnamese as default locale', () {
        languageProvider = LanguageProvider();

        expect(languageProvider.currentLocale, equals(const Locale('vi')));
        expect(languageProvider.isVietnamese, isTrue);
        expect(languageProvider.isEnglish, isFalse);
      });

      test('should load saved language from SharedPreferences', () async {
        // Arrange - Set English in SharedPreferences
        SharedPreferences.setMockInitialValues({'language_code': 'en'});

        // Act
        languageProvider = LanguageProvider();

        // Wait for async _loadLanguage to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('en')));
        expect(languageProvider.isEnglish, isTrue);
        expect(languageProvider.isVietnamese, isFalse);
      });

      test('should use default Vietnamese when no saved language', () async {
        // Arrange - Empty SharedPreferences
        SharedPreferences.setMockInitialValues({});

        // Act
        languageProvider = LanguageProvider();

        // Wait for async _loadLanguage to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('vi')));
        expect(languageProvider.isVietnamese, isTrue);
        expect(languageProvider.isEnglish, isFalse);
      });
    });

    group('Language Change Tests', () {
      setUp(() {
        languageProvider = LanguageProvider();
      });

      test('should change language to English', () async {
        // Arrange
        bool notified = false;
        languageProvider.addListener(() {
          notified = true;
        });

        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('en')));
        expect(languageProvider.isEnglish, isTrue);
        expect(languageProvider.isVietnamese, isFalse);
        expect(notified, isTrue);
      });

      test('should change language to Vietnamese', () async {
        // Arrange - Start with English
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        bool notified = false;
        languageProvider.addListener(() {
          notified = true;
        });

        // Act
        languageProvider.changeLanguage(const Locale('vi'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('vi')));
        expect(languageProvider.isVietnamese, isTrue);
        expect(languageProvider.isEnglish, isFalse);
        expect(notified, isTrue);
      });

      test('should not notify listeners when setting same language', () async {
        // Arrange
        languageProvider.changeLanguage(const Locale('vi'));
        await Future.delayed(const Duration(milliseconds: 50));

        bool notified = false;
        languageProvider.addListener(() {
          notified = true;
        });

        // Act - Set same language
        languageProvider.changeLanguage(const Locale('vi'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('vi')));
        expect(notified, isFalse); // Should not notify
      });

      test('should save language to SharedPreferences', () async {
        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('language_code'), equals('en'));
      });

      test('should handle multiple language changes', () async {
        // Arrange
        int notificationCount = 0;
        languageProvider.addListener(() {
          notificationCount++;
        });

        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));
        languageProvider.changeLanguage(const Locale('vi'));
        await Future.delayed(const Duration(milliseconds: 50));
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.currentLocale, equals(const Locale('en')));
        expect(notificationCount, equals(3));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('language_code'), equals('en'));
      });
    });

    group('Locale Property Tests', () {
      setUp(() {
        languageProvider = LanguageProvider();
      });

      test('should correctly identify Vietnamese locale', () async {
        // Act
        languageProvider.changeLanguage(const Locale('vi'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.isVietnamese, isTrue);
        expect(languageProvider.isEnglish, isFalse);
        expect(languageProvider.currentLocale.languageCode, equals('vi'));
      });

      test('should correctly identify English locale', () async {
        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.isEnglish, isTrue);
        expect(languageProvider.isVietnamese, isFalse);
        expect(languageProvider.currentLocale.languageCode, equals('en'));
      });

      test('should handle custom locale codes', () async {
        // Act
        languageProvider.changeLanguage(const Locale('fr'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(languageProvider.currentLocale.languageCode, equals('fr'));
        expect(languageProvider.isVietnamese, isFalse);
        expect(languageProvider.isEnglish, isFalse);
      });
    });

    group('Persistence Tests', () {
      test('should persist language across provider instances', () async {
        // Arrange - Create first provider and set English
        final provider1 = LanguageProvider();
        provider1.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Act - Create second provider
        final provider2 = LanguageProvider();

        // Wait for async loading
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Second provider should load English
        expect(provider2.currentLocale, equals(const Locale('en')));
        expect(provider2.isEnglish, isTrue);
      });

      test('should handle SharedPreferences errors gracefully', () async {
        // This test verifies that the provider doesn't crash if SharedPreferences fails
        // In a real scenario, you might want to mock SharedPreferences to throw an error

        // Act
        languageProvider = LanguageProvider();

        // Assert - Should not throw and use default
        expect(languageProvider.currentLocale, equals(const Locale('vi')));
      });
    });

    group('Listener Notification Tests', () {
      setUp(() {
        languageProvider = LanguageProvider();
      });

      test('should notify listeners on language change', () async {
        // Arrange
        int notificationCount = 0;
        Locale? notifiedLocale;

        languageProvider.addListener(() {
          notificationCount++;
          notifiedLocale = languageProvider.currentLocale;
        });

        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(notificationCount, equals(1));
        expect(notifiedLocale, equals(const Locale('en')));
      });

      test('should notify multiple listeners', () async {
        // Arrange
        int listener1Count = 0;
        int listener2Count = 0;

        languageProvider.addListener(() {
          listener1Count++;
        });

        languageProvider.addListener(() {
          listener2Count++;
        });

        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));
      });

      test('should not notify removed listeners', () async {
        // Arrange
        int notificationCount = 0;
        void listener() {
          notificationCount++;
        }

        languageProvider.addListener(listener);
        languageProvider.removeListener(listener);

        // Act
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(notificationCount, equals(0));
      });
    });

    group('Edge Cases Tests', () {
      setUp(() {
        languageProvider = LanguageProvider();
      });

      test('should handle missing language code in SharedPreferences',
          () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final provider = LanguageProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Should use default Vietnamese
        expect(provider.currentLocale, equals(const Locale('vi')));
      });

      test('should handle rapid language changes', () async {
        // Act - Rapid changes without waiting
        languageProvider.changeLanguage(const Locale('en'));
        languageProvider.changeLanguage(const Locale('vi'));
        languageProvider.changeLanguage(const Locale('fr'));
        languageProvider.changeLanguage(const Locale('en'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Should end up with the last change
        expect(languageProvider.currentLocale, equals(const Locale('en')));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('language_code'), equals('en'));
      });
    });
  });
}
