import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_student_history_response.dart';

class OyunGrubuStudentHistoryService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuStudentHistoryResponse>> getStudentHistory({
    required int studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.studentHistory,
        body: {
          'user_key': userKey,
          'student_id': studentId.toString(),
        },
      );
      final historyResponse =
          OyunGrubuStudentHistoryResponse.fromJson(response);
      return Success(historyResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getStudentHistory failed', e);
      return Failure(e.toString());
    }
  }
}
