import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/app_translations.dart';
import 'base_view_model.dart';

class SplashViewModel extends BaseViewModel {
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'tr';
    _locale = Locale(lang);
    await AppTranslations.load(lang);
    notifyListeners();
  }
}
