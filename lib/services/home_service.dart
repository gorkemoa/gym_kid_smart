import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/notice_model.dart';
import '../models/student_model.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<List<NoticeModel>>> getAllNotices({
    required int schoolId,
    required String userKey,
    required int classId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allNotices,
        body: {'school_id': schoolId, 'user_key': userKey, 'class_id': classId},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final notices = data.map((json) => NoticeModel.fromJson(json)).toList();
        return Success(notices);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch notices failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<StudentModel>>> getAllStudents({
    required int schoolId,
    required String userKey,
    int classId = 0,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allStudents,
        body: {'school_id': schoolId, 'user_key': userKey, 'class_id': classId},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final students = data
            .map((json) => StudentModel.fromJson(json))
            .toList();
        return Success(students);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch students failed', e);
      return Failure(e.toString());
    }
  }
}
