import 'package:flutter/material.dart';
import '../core/utils/app_translations.dart';

class LandingViewModel extends ChangeNotifier {
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  Future<void> init() async {
    await AppTranslations.load(_locale.languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await AppTranslations.load(languageCode);
    notifyListeners();
  }

  // Navigation logic can be handled here or in the view
}
