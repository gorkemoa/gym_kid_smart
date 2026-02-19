import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_notifications_response.dart';

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
      return Failure(e.toString());
    }
  }
}
