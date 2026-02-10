import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';
import '../core/utils/logger.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authServiceData = AuthService();
  final PushNotificationService _pushService = PushNotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _data;
  LoginResponse? get data => _data;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void init() {
    emailController.text = 'b.sekman@smartmetrics.com.tr';
    passwordController.text = '123123';
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

    final result = await _authServiceData.login(
      emailController.text,
      passwordController.text,
    );

    _setLoading(false);

    if (result is Success<LoginResponse>) {
      _data = result.data;

      // Send device token after login for personalized notifications
      // addtoken da ki bildirim işlemlerine başka zaman bakılacak
      if (_data?.data != null) {
        final user = _data!.data!;
        _pushService
            .addToken(
              schoolId: user.schoolId ?? 1,
              userKey: user.userKey ?? '',
              deviceId: 'temp_device_id', // TODO: Get actual FCM token later
            )
            .then((res) {
              if (res is Success) {
                AppLogger.info('Push token registered successfully');
              } else if (res is Failure) {
                AppLogger.warning(
                  'Push token registration failed: ${res.message}',
                );
              }
            });
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
