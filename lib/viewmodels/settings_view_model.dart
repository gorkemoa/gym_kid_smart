import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../core/network/api_result.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  SettingsData? _settings;
  SettingsData? get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings({int? schoolId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _settingsService.getSettings(schoolId: schoolId);

    if (result is Success<SettingsResponse>) {
      _settings = result.data.data;
      _isLoading = false;
      notifyListeners();
    } else if (result is Failure<SettingsResponse>) {
      _errorMessage = result.message;
      _isLoading = false;
      notifyListeners();
    }
  }
}
