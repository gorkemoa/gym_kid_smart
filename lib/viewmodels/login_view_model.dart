import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authServiceData = AuthService();

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
