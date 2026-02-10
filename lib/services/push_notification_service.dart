import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';

class PushNotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<bool>> addToken({
    required int schoolId,
    required String userKey,
    required String deviceId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addToken,
        body: {'school_id': schoolId, 'user_key': userKey, 'token': deviceId},
      );

      // Postman example shows: {"success": "İstek Başarılı", "data": true}
      if (response['data'] == true) {
        return Success(true);
      } else {
        return Failure(response['success'] ?? 'Token ekleme başarısız');
      }
    } catch (e) {
      AppLogger.error('Add token failed', e);
      return Failure(e.toString());
    }
  }
}
