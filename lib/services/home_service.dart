import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/notice_model.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/daily_student_model.dart';
import '../models/activity_value_model.dart';
import '../models/activity_title_model.dart';
import '../models/social_title_model.dart';
import '../models/meal_title_model.dart';
import '../models/meal_value_model.dart';
import '../models/student_medicament_model.dart';

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

  Future<ApiResult<bool>> addDailySocial({
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
        ApiConstants.dailySocial,
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
        response['message'] ?? response['failure'] ?? 'Sosyal eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily social failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<ActivityTitleModel>>> getAllActivitiesTitle({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allActivitiesTitle,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final titles = data
            .map((json) => ActivityTitleModel.fromJson(json))
            .toList();
        return Success(titles);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch activity titles failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<ActivityValueModel>>> getAllActivitiesValue({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allActivitiesValue,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final values = data
            .map((json) => ActivityValueModel.fromJson(json))
            .toList();
        return Success(values);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch activity values failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> saveActivityValue({
    required int schoolId,
    required String userKey,
    required String value,
    int? id,
  }) async {
    try {
      final body = {'school_id': schoolId, 'user_key': userKey, 'value': value};
      if (id != null) body['id'] = id;

      final response = await _apiClient.post(
        ApiConstants.activitiesValue,
        body: body,
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Değer kaydedilemedi',
      );
    } catch (e) {
      AppLogger.error('Save activity value failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> saveActivityTitle({
    required int schoolId,
    required String userKey,
    required String title,
    int? id,
  }) async {
    try {
      final body = {'school_id': schoolId, 'user_key': userKey, 'title': title};
      if (id != null) body['id'] = id;

      final response = await _apiClient.post(
        ApiConstants.activitiesTitle,
        body: body,
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Başlık kaydedilemedi',
      );
    } catch (e) {
      AppLogger.error('Save activity title failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<SocialTitleModel>>> getAllSocialsTitle({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allSocialsTitle,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final titles = data
            .map((json) => SocialTitleModel.fromJson(json))
            .toList();
        return Success(titles);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch social titles failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> saveSocialTitle({
    required int schoolId,
    required String userKey,
    required String title,
    int? id,
  }) async {
    try {
      final body = {'school_id': schoolId, 'user_key': userKey, 'title': title};
      if (id != null) body['id'] = id;

      final response = await _apiClient.post(
        ApiConstants.socialsTitle,
        body: body,
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ??
            response['failure'] ??
            'Sosyal başlık kaydedilemedi',
      );
    } catch (e) {
      AppLogger.error('Save social title failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<MealTitleModel>>> getAllMealsTitle({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allMealsTitle,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final titles = data
            .map((json) => MealTitleModel.fromJson(json))
            .toList();
        return Success(titles);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch meal titles failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<MealValueModel>>> getAllMealsValue({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allMealsValue,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final values = data
            .map((json) => MealValueModel.fromJson(json))
            .toList();
        return Success(values);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch meal values failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyMeal({
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
        ApiConstants.dailyMeal,
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
        response['message'] ?? response['failure'] ?? 'Yemek eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily meal failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<StudentMedicamentModel>>> getStudentMedicament({
    required int schoolId,
    required String userKey,
    required int studentId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.studentMedicament,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
        },
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final items = data
            .map((json) => StudentMedicamentModel.fromJson(json))
            .toList();
        return Success(items);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch student medicament failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addStudentMedicament({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String name,
    required String time,
    required String note,
    required int status,
    required int id,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addStudentMedicament,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'name': name,
          'time': time,
          'note': note,
          'status': status,
          'id': id,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'İşlem başarısız',
      );
    } catch (e) {
      AppLogger.error('Add/Delete student medicament failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> toggleDailyMedicament({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String date,
    required int userId,
    required int medicamentId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyMedicament,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'date': date,
          'user_id': userId,
          'medicament_id': medicamentId,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'İşlem başarısız',
      );
    } catch (e) {
      AppLogger.error('Toggle daily medicament failed', e);
      return Failure(e.toString());
    }
  }
}
