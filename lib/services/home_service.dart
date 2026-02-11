import '../models/activity_value_model.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  // Existing methods...
  // (Assuming I should just append since replace_file_content is for contiguous blocks)
  // I will scroll down and append to the end of the class.

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

  Future<ApiResult<List<ClassModel>>> getAllClasses({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allClasses,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final classes = data.map((json) => ClassModel.fromJson(json)).toList();
        return Success(classes);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch classes failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<DailyStudentModel>>> getDailyStudent({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String date,
    required String part,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyStudent,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'date': date,
          'part': part,
        },
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final items = data
            .map((json) => DailyStudentModel.fromJson(json))
            .toList();
        return Success(items);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch daily student data failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyStudentsNote({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String teacherNote,
    required String parentNote,
    required int teacherStatus,
    required int parentStatus,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyStudentsNote,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'teacher_note': teacherNote,
          'parent_note': parentNote,
          'teacher_status': teacherStatus,
          'parent_status': parentStatus,
          'date': date,
        },
      );

      // API returns success message in 'success' and result in 'data'
      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Not eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily student note failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyReceiving({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String date,
    required String time,
    required String recipient,
    required int status,
    required int userId,
    required String note,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyReceiving,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'date': date,
          'time': time,
          'recipient': recipient,
          'status': status,
          'user_id': userId,
          'note': note,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'İşlem başarısız',
      );
    } catch (e) {
      AppLogger.error('Add daily receiving failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyActivity({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String title,
    required String value,
    required String note,
    required String date,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyActivity,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'title': title,
          'value': value,
          'note': note,
          'date': date,
          'user_id': userId,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Aktivite eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily activity failed', e);
      return Failure(e.toString());
    }
  }
}
