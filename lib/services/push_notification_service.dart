import 'package:firebase_messaging/firebase_messaging.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';

import '../core/utils/error_mapper.dart';

class PushNotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<bool>> addToken({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return const Failure('fcm_token_null');

      final response = await _apiClient.post(
        ApiConstants.addToken,
        body: {'school_id': schoolId, 'user_key': userKey, 'token': fcmToken},
      );

      // Postman example shows: {"success": "İstek Başarılı", "data": true}
      if (response['data'] == true) {
        return const Success(true);
      } else {
        return Failure(
          ErrorMapper.mapMessage(
            response['success'] ?? 'Token ekleme başarısız',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Add token failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }
}
