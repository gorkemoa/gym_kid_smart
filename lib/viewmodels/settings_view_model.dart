import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_view_model.dart';
import '../app/app_theme.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/home_service.dart';
import '../models/activity_title_model.dart';
import '../models/activity_value_model.dart';
import '../models/social_title_model.dart';
import '../core/network/api_result.dart';
import '../models/student_model.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsService _settingsService = SettingsService();
  final HomeService _homeService = HomeService();

  SettingsData? _settings;
  SettingsData? get settings => _settings;

  String? _baseUrl;
  String? get baseUrl => _baseUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ActivityTitleModel> _activityTitles = [];
  List<ActivityTitleModel> get activityTitles => _activityTitles;

  List<ActivityValueModel> _activityValues = [];
  List<ActivityValueModel> get activityValues => _activityValues;

  List<SocialTitleModel> _socialTitles = [];
  List<SocialTitleModel> get socialTitles => _socialTitles;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  bool _isReceivingLoading = false;
  bool get isReceivingLoading => _isReceivingLoading;

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

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getString('saved_settings');
    _baseUrl = prefs.getString('saved_settings_url');

    if (savedSettings != null) {
      try {
        _settings = SettingsData.fromJson(jsonDecode(savedSettings));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading saved settings: $e');
      }
    }
  }

  Future<void> fetchSettings({int? schoolId}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _settingsService.getSettings(schoolId: schoolId);

      _isLoading = false;
      if (result is Success<SettingsResponse>) {
        _settings = result.data.data;
        _baseUrl = result.data.url;

        // Persist settings
        final prefs = await SharedPreferences.getInstance();
        if (_settings != null) {
          await prefs.setString(
            'saved_settings',
            jsonEncode(_settings!.toJson()),
          );
        }
        if (_baseUrl != null) {
          await prefs.setString('saved_settings_url', _baseUrl!);
        }

        notifyListeners();
      } else if (result is Failure<SettingsResponse>) {
        _errorMessage = result.message;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTemplates({
    required int schoolId,
    required String userKey,
  }) async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _homeService.getAllActivitiesTitle(schoolId: schoolId, userKey: userKey),
      _homeService.getAllActivitiesValue(schoolId: schoolId, userKey: userKey),
      _homeService.getAllSocialsTitle(schoolId: schoolId, userKey: userKey),
    ]);

    if (results[0] is Success<List<ActivityTitleModel>>) {
      _activityTitles = (results[0] as Success<List<ActivityTitleModel>>).data;
    }
    if (results[1] is Success<List<ActivityValueModel>>) {
      _activityValues = (results[1] as Success<List<ActivityValueModel>>).data;
    }
    if (results[2] is Success<List<SocialTitleModel>>) {
      _socialTitles = (results[2] as Success<List<SocialTitleModel>>).data;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResult<bool>> saveActivityTitle({
    required int schoolId,
    required String userKey,
    required String title,
  }) async {
    final result = await _homeService.saveActivityTitle(
      schoolId: schoolId,
      userKey: userKey,
      title: title,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> saveActivityValue({
    required int schoolId,
    required String userKey,
    required String value,
  }) async {
    final result = await _homeService.saveActivityValue(
      schoolId: schoolId,
      userKey: userKey,
      value: value,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> saveSocialTitle({
    required int schoolId,
    required String userKey,
    required String title,
  }) async {
    final result = await _homeService.saveSocialTitle(
      schoolId: schoolId,
      userKey: userKey,
      title: title,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> deleteActivityTitle({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    final result = await _homeService.deleteActivityTitle(
      schoolId: schoolId,
      userKey: userKey,
      id: id,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> deleteActivityValue({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    final result = await _homeService.deleteActivitiesValue(
      schoolId: schoolId,
      userKey: userKey,
      id: id,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> deleteSocialTitle({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    final result = await _homeService.deleteSocialsTitle(
      schoolId: schoolId,
      userKey: userKey,
      id: id,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<ApiResult<bool>> deleteSocialValue({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    final result = await _homeService.deleteSocialsValue(
      schoolId: schoolId,
      userKey: userKey,
      id: id,
    );
    if (result is Success) {
      await fetchTemplates(schoolId: schoolId, userKey: userKey);
    }
    return result;
  }

  Future<void> fetchStudents({
    required int schoolId,
    required String userKey,
  }) async {
    _isReceivingLoading = true;
    notifyListeners();

    final result = await _homeService.getAllStudents(
      schoolId: schoolId,
      userKey: userKey,
    );

    if (result is Success<List<StudentModel>>) {
      _students = result.data;
    }

    _isReceivingLoading = false;
    notifyListeners();
  }

  Future<ApiResult<bool>> saveReceiving({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String date,
    required String time,
    required String recipient,
    required int status,
    required int userId,
    required String note,
  }) async {
    return await _homeService.addDailyReceiving(
      schoolId: schoolId,
      userKey: userKey,
      studentId: studentId,
      date: date,
      time: time,
      recipient: recipient,
      status: status,
      userId: userId,
      note: note,
    );
  }
}
