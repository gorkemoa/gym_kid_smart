import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../models/settings_model.dart';
import '../core/utils/logger.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<SettingsResponse>> getSettings({int? schoolId}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allSettings,
        // schoolId 1 gidecek hep şimdilik
        body: {'school_id': 1},
      );

      final settingsResponse = SettingsResponse.fromJson(response);
      return Success(settingsResponse);
    } catch (e) {
      AppLogger.error('Fetch settings failed', e);
      return Failure(e.toString());
    }
  }
}
