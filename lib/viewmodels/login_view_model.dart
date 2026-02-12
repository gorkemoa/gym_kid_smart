import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';
import '../services/device_info_service.dart';
import '../core/utils/logger.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PushNotificationService _pushService = PushNotificationService();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _data;
  LoginResponse? get data => _data;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> init() async {
    emailController.text = 'b.sekman@smartmetrics.com.tr';
    passwordController.text = '123123';

    final savedUser = await _authService.getSavedUser();
    if (savedUser != null) {
      _data = LoginResponse(success: 'true', data: savedUser);
      notifyListeners();
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

    if (result is Success<LoginResponse>) {
      _data = result.data;

      // Send device token after login for personalized notifications
      if (_data?.data != null) {
        final user = _data!.data!;

        final deviceId = await _deviceInfoService.getDeviceId();
        final res = await _pushService.addToken(
          schoolId: user.schoolId ?? 1,
          userKey: user.userKey ?? '',
          deviceId: deviceId,
        );

        if (res is Success<bool>) {
          AppLogger.info(
            'Push token registered successfully with ID: $deviceId',
          );
        } else if (res is Failure<bool>) {
          AppLogger.warning('Push token registration failed: ${res.message}');
        }
      }

      notifyListeners();
      return true;
    } else if (result is Failure<LoginResponse>) {
      _errorMessage = result.message;
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
