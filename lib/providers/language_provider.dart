import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  bool _isEnglish = true;
  bool get isEnglish => _isEnglish;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnglish = prefs.getBool('isEnglish') ?? true;
      notifyListeners();
    } catch (e) {
      _isEnglish = true;
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    try {
      _isEnglish = !_isEnglish;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isEnglish', _isEnglish);
      notifyListeners();
    } catch (e) {
      // If there's an error saving the preference, revert the change
      _isEnglish = !_isEnglish;
      notifyListeners();
    }
  }

  String getText(String englishText, String russianText) {
    return _isEnglish ? englishText : russianText;
  }

  // Common translations
  static const Map<String, String> translations = {
    'News Headlines': 'Новости',
    'Article Details': 'Детали статьи',
    'Read Full Article': 'Читать полную статью',
    'Page': 'Страница',
    'All': 'Все',
    'Politics': 'Политика',
    'Economy': 'Экономика',
    'Social': 'Общество',
    'Culture': 'Культура',
    'Sports': 'Спорт',
    'Technology': 'Технологии',
    'Health': 'Здоровье',
    'Science': 'Наука',
    'Entertainment': 'Развлечения',
  };
} 