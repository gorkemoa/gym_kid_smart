import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_students_response.dart';
import '../core/utils/error_mapper.dart';

class OyunGrubuStudentService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuStudentsResponse>> getStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.students,
        body: {'user_key': userKey},
      );
      final studentsResponse = OyunGrubuStudentsResponse.fromJson(response);
      return Success(studentsResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getStudents failed', e);
      return Failure(ErrorMapper.mapMessage(e));
    }
  }
}
