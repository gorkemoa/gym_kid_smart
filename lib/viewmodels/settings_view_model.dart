import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/home_service.dart';
import '../models/activity_title_model.dart';
import '../models/activity_value_model.dart';
import '../models/social_title_model.dart';
import '../core/network/api_result.dart';

class SettingsViewModel extends ChangeNotifier {
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
}
