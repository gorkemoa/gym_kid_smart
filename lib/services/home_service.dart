import 'dart:io';
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
import '../models/calendar_detail_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../models/meal_menu_model.dart';
import '../models/user_model.dart';

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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
      AppLogger.error('Fetch notices failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> saveNotice({
    required int schoolId,
    required String userKey,
    required int classId,
    required String title,
    required String description,
    required String date,
    required int status,
    required int id,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.notices,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'class_id': classId,
          'title': title,
          'description': description,
          'date': date,
          'status': status,
          'id': id,
          'user_id': userId,
        },
      );

      if (response['success'] != null) {
        return const Success(true);
      }
      return Failure(response['message'] ?? 'Operation failed');
    } catch (e) {
      AppLogger.error('Save notice failed', e);
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
      if (e.toString().contains('Öğrenci Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
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

  Future<ApiResult<List<MealMenuModel>>> getMealMenus({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allMealMenus,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final items = data.map((json) => MealMenuModel.fromJson(json)).toList();
        return Success(items);
      }
      return Success([]);
    } catch (e) {
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
      AppLogger.error('Fetch meal menus failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyMealMenu({
    required int schoolId,
    required String userKey,
    required String title,
    required String menu,
    required String time,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyMealMenus,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'title': title,
          'menu': menu,
          'time': time,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Yemek menüsü eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily meal menu failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteMealMenu({
    required int schoolId,
    required String userKey,
    required String time,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteMealMenu,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'time': time,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete meal menu failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyGallery({
    required int schoolId,
    required String userKey,
    required int classId,
    required File image,
    required String date,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.dailyGallery,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'class_id': classId,
          'date': date,
          'user_id': userId,
        },
        files: {'image': image},
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Galeri eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily gallery failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteGallery({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteGallery,
        body: {'school_id': schoolId, 'user_key': userKey, 'id': id},
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete gallery failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<LessonModel>>> getAllLessons({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allLessons,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final items = data.map((json) => LessonModel.fromJson(json)).toList();
        return Success(items);
      }
      return Success([]);
    } catch (e) {
      if (e.toString().contains('Bulunamadı')) {
        return const Success([]);
      }
      AppLogger.error('Fetch lessons failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addDailyTimeTable({
    required int schoolId,
    required String userKey,
    required int classId,
    required int lessonId,
    required String description,
    required String date,
    required String startTime,
    required String endTime,
    required int userId,
    File? file,
  }) async {
    try {
      final body = {
        'school_id': schoolId,
        'user_key': userKey,
        'class_id': classId,
        'lesson_id': lessonId,
        'description': description,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'user_id': userId,
      };

      final response = await _apiClient.post(
        ApiConstants.dailyTimeTable,
        body: body,
        files: file != null ? {'file': file} : null,
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ??
            response['failure'] ??
            'Ders programı eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add daily time table failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteTimeTable({
    required int schoolId,
    required String userKey,
    required int classId,
    required int lessonId,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteTimeTable,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'class_id': classId,
          'lesson_id': lessonId,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete time table failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<CalendarDetailModel>> getCalendarDetail({
    required int schoolId,
    required String userKey,
    required String date,
    required int classId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.calendarDetail,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'date': date,
          'class_id': classId,
        },
      );

      if (response['data'] != null) {
        final data = CalendarDetailModel.fromJson(response['data']);
        return Success(data);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Veri bulunamadı',
      );
    } catch (e) {
      AppLogger.error('Fetch calendar detail failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteDailySocial({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String title,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteDailySocial,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'title': title,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete daily social failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteDailyActivity({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String title,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteDailyActivity,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'title': title,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete daily activity failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteDailyMeal({
    required int schoolId,
    required String userKey,
    required int studentId,
    required String title,
    required String date,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.deleteDailyMeal,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'student_id': studentId,
          'title': title,
          'date': date,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'Silme işlemi başarısız',
      );
    } catch (e) {
      AppLogger.error('Delete daily meal failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<ChatRoomModel>>> getChatRooms({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getChatRoom,
        body: {'school_id': schoolId, 'user_key': userKey, 'id': id},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final chatRooms = data
            .map((json) => ChatRoomModel.fromJson(json))
            .toList();
        return Success(chatRooms);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch chat rooms failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<ChatMessageModel>>> getChatDetail({
    required int schoolId,
    required String userKey,
    required int id,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getChatDetail,
        body: {'school_id': schoolId, 'user_key': userKey, 'id': id},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final messages = data
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
        return Success(messages);
      }
      return Success([]);
    } catch (e) {
      if (e.toString().contains('Hata')) {
        return const Success([]);
      }
      AppLogger.error('Fetch chat detail failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> addChatDetail({
    required int schoolId,
    required String userKey,
    required int id,
    required String description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addChatDetail,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'id': id,
          'description': description,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(response['message'] ?? 'Mesaj gönderilemedi');
    } catch (e) {
      AppLogger.error('Add chat detail failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<int>> addChatRoom({
    required int schoolId,
    required String userKey,
    required int recipientUser,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addChatRoom,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'recipient_user': recipientUser,
        },
      );

      // Check multiple possible fields for room ID
      final rawId =
          response['id'] ?? response['message_id'] ?? response['data'];

      if (rawId != null) {
        final id = int.tryParse(rawId.toString());
        if (id != null && id != 0) {
          return Success(id);
        }
      }

      return Failure(response['message'] ?? 'Sohbet ID alınamadı');
    } catch (e) {
      AppLogger.error('Add chat room failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<UserModel>>> getAllTeachers({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allTeachers,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final teachers = data.map((json) => UserModel.fromJson(json)).toList();
        return Success(teachers);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch all teachers failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<UserModel>>> getAllParents({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allParents,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final parents = data.map((json) => UserModel.fromJson(json)).toList();
        return Success(parents);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch all parents failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<UserModel>>> getAllAdmins({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.allAdmin,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final admins = data.map((json) => UserModel.fromJson(json)).toList();
        return Success(admins);
      }
      return Success([]);
    } catch (e) {
      AppLogger.error('Fetch all admins failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> updateStatusChat({
    required int schoolId,
    required String userKey,
    required int id,
    required int status,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.updateStatusChat,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'id': id,
          'status': status,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return Success(true);
      }
      return Failure(response['message'] ?? 'Durum güncellenemedi');
    } catch (e) {
      AppLogger.error('Update chat status failed', e);
      return Failure(e.toString());
    }
  }
}
