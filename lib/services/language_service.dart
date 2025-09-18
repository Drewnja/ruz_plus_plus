import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('zh', ''),
    Locale('lo', ''),
    Locale('uk', ''),
    Locale('uz', ''),
  ];
  
  static const Locale defaultLocale = Locale('en', '');
  
  /// Get the saved language preference
  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    return defaultLocale;
  }
  
  /// Save language preference
  static Future<void> saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
  
  /// Get language display name
  static String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English 🇺🇸';
      case 'ru':
        return 'Русский 🇷🇺';
      case 'zh':
        return '中文 🇨🇳';
      case 'lo':
        return 'ລາວ 🇱🇦';
      case 'uk':
        return 'Українська 🇺🇦';
      case 'uz':
        return 'O\'zbek 🇺🇿';
      default:
        return 'English 🇺🇸';
    }
  }
  
  /// Get language name for ARB files
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'lo':
        return 'ລາວ';
      case 'uk':
        return 'Українська';
      case 'uz':
        return 'O\'zbek';
      default:
        return 'English';
    }
  }
}
