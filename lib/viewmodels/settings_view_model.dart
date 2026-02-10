import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../core/network/api_result.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  SettingsData? _settings;
  SettingsData? get settings => _settings;

  String? _baseUrl;
  String? get baseUrl => _baseUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ThemeData get themeData {
    return AppTheme.getTheme(
      mainColor: _settings?.mainColor,
      otherColor: _settings?.otherColor,
    );
  }

  String get logoFullUrl {
    if (_baseUrl != null && _settings?.logo != null) {
      return '$_baseUrl${_settings!.logo}';
    }
    return '';
  }

  Future<void> fetchSettings({int? schoolId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _settingsService.getSettings(schoolId: schoolId);

    if (result is Success<SettingsResponse>) {
      _settings = result.data.data;
      _baseUrl = result.data.url;
      _isLoading = false;
      notifyListeners();
    } else if (result is Failure<SettingsResponse>) {
      _errorMessage = result.message;
      _isLoading = false;
      notifyListeners();
    }
  }
}
