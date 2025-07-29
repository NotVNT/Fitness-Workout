import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('vi'); // Mặc định là tiếng Việt
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  void changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
  
  bool get isVietnamese => _currentLocale.languageCode == 'vi';
  bool get isEnglish => _currentLocale.languageCode == 'en';
}
