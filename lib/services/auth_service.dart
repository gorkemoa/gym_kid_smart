import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../models/login_response.dart';
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
      return Success(loginResponse);
    } catch (e) {
      AppLogger.error('Login failed', e);
      return Failure(e.toString());
    }
  }
}
