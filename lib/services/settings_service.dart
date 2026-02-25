import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../models/settings_model.dart';
import '../core/utils/logger.dart';

import '../core/utils/error_mapper.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<SettingsResponse>> getSettings({int? schoolId}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allSettings,
        body: schoolId != null ? {'school_id': schoolId} : null,
      );

      final settingsResponse = SettingsResponse.fromJson(response);
      return Success(settingsResponse);
    } catch (e) {
      AppLogger.error('Fetch settings failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }
}
