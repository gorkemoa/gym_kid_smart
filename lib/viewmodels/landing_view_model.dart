import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/app_translations.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LandingViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code');

    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    } else {
      // If no saved language, use device language (default to 'tr' if not 'en')
      final deviceLocale = PlatformDispatcher.instance.locale;
      final String languageCode = deviceLocale.languageCode == 'en'
          ? 'en'
          : 'tr';
      _locale = Locale(languageCode);
      await prefs.setString('language_code', languageCode);
    }

    await AppTranslations.load(_locale.languageCode);
    _user = await _authService.getSavedUser();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    await AppTranslations.load(languageCode);
    notifyListeners();
  }
}
