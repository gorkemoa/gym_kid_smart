import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_announcements_response.dart';
import '../core/utils/error_mapper.dart';

class OyunGrubuAnnouncementService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuAnnouncementsResponse>> getAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getAnnouncements,
        body: {'user_key': userKey},
      );
      final announcementsResponse =
          OyunGrubuAnnouncementsResponse.fromJson(response);
      return Success(announcementsResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getAnnouncements failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }

  Future<ApiResult<bool>> votePoll({
    required int announcementId,
    required String vote,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.votePoll,
        body: {
          'user_key': userKey,
          'announcement_id': announcementId.toString(),
          'vote': vote,
        },
      );

      if (response['success'] != null) {
        return const Success(true);
      } else {
        return Failure(
          ErrorMapper.mapMessage(response['failure'] ?? 'Vote failed'),
        );
      }
    } catch (e) {
      AppLogger.error('OyunGrubu votePoll failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }
}
