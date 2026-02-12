import 'package:flutter/material.dart';
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
    await AppTranslations.load(_locale.languageCode);
    _user = await _authService.getSavedUser();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await AppTranslations.load(languageCode);
    notifyListeners();
  }
}
