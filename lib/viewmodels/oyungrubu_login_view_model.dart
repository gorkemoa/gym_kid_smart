import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_login_response.dart';
import '../services/oyungrubu_auth_service.dart';
import '../services/oyungrubu_notification_service.dart';
import '../core/utils/logger.dart';

class OyunGrubuLoginViewModel extends BaseViewModel {
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();
  final OyunGrubuNotificationService _pushService =
      OyunGrubuNotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OyunGrubuLoginResponse? _data;
  OyunGrubuLoginResponse? get data => _data;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> init() async {
    final savedUser = await _authService.getSavedUser();
    if (savedUser != null) {
      _data = OyunGrubuLoginResponse(success: 'true', data: savedUser);
      notifyListeners();
    } else {
      _data = null;
    }
  }

  void refresh() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void onRetry() {
    login();
  }

  Future<bool> login() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    _setLoading(false);

    if (result is Success<OyunGrubuLoginResponse>) {
      _data = result.data;
      AppLogger.info(
        'OyunGrubu login successful: ${_data?.data?.name} ${_data?.data?.surname}',
      );

      final pushRes = await _pushService.updateFCMToken();
      if (pushRes is Success<bool>) {
        AppLogger.info('OyunGrubu push token registered!');
      } else if (pushRes is Failure<bool>) {
        AppLogger.warning(
          'OyunGrubu push token registration failed: ${pushRes.message}',
        );
      }
      notifyListeners();
      return true;
    } else if (result is Failure<OyunGrubuLoginResponse>) {
      _errorMessage = result.message;
      AppLogger.warning('OyunGrubu login failed: ${result.message}');
      notifyListeners();
      return false;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
