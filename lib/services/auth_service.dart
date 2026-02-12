import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../core/utils/logger.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<LoginResponse>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(response);

      if (loginResponse.data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', loginResponse.data!.role ?? '');
        await prefs.setString(
          'user_data',
          jsonEncode(loginResponse.data!.toJson()),
        );
      }

      return Success(loginResponse);
    } catch (e) {
      AppLogger.error('Login failed', e);
      return Failure(e.toString());
    }
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_role');
  }
}
