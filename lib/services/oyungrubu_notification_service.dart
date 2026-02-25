import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_notifications_response.dart';
import '../core/utils/error_mapper.dart';

class OyunGrubuNotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuNotificationsResponse>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getNotifications,
        body: {'user_key': userKey},
      );
      final notificationsResponse = OyunGrubuNotificationsResponse.fromJson(
        response,
      );
      return Success(notificationsResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getNotifications failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }

  Future<ApiResult<bool>> updateFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        return const Failure('fcm_token_null');
      }

      final response = await _apiClient.post(
        ApiConstants.updateFCMToken,
        body: {'user_key': userKey, 'fcm_token': fcmToken},
      );

      if (response['success'] != null) {
        return const Success(true);
      } else {
        return Failure(
          ErrorMapper.mapMessage(
            response['failure'] ?? 'Update Fcm token failed',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('OyunGrubu updateFCMToken failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }

  Future<ApiResult<bool>> markNotificationRead({
    required int notificationId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.markNotificationRead,
        body: {
          'user_key': userKey,
          'notification_id': notificationId.toString(),
        },
      );

      // response format logic based on typical API structure
      if (response != null && response['success'] != null) {
        return const Success(true);
      } else {
        return Failure(
          ErrorMapper.mapMessage(
            response['failure'] ?? 'Failed to mark as read',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('OyunGrubu markNotificationRead failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }
}
