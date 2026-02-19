import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_classes_response.dart';
import '../models/oyungrubu_timetable_response.dart';
import '../models/oyungrubu_lessons_response.dart';
import '../models/oyungrubu_lesson_detail_response.dart';

class OyunGrubuClassService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuClassesResponse>> getClasses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.oyunGrubuClasses,
        body: {'user_key': userKey},
      );
      final classesResponse = OyunGrubuClassesResponse.fromJson(response);
      return Success(classesResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getClasses failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuTimetableResponse>> getTimeTable({
    required int classId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.oyunGrubuTimeTable,
        body: {'user_key': userKey, 'class_id': classId.toString()},
      );
      final timetableResponse = OyunGrubuTimetableResponse.fromJson(response);
      return Success(timetableResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getTimeTable failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuLessonsResponse>> getLessons({
    required int studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.oyunGrubuLessons,
        body: {'user_key': userKey, 'student_id': studentId.toString()},
      );
      final lessonsResponse = OyunGrubuLessonsResponse.fromJson(response);
      return Success(lessonsResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getLessons failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuLessonsResponse>> getUpcomingLessons({
    required int studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.oyunGrubuUpcomingLessons,
        body: {'user_key': userKey, 'student_id': studentId.toString()},
      );
      final lessonsResponse = OyunGrubuLessonsResponse.fromJson(response);
      return Success(lessonsResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getUpcomingLessons failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuLessonDetailResponse>> getLessonDetails({
    required int studentId,
    required int lessonId,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getLessonDetails,
        body: {
          'user_key': userKey,
          'student_id': studentId.toString(),
          'lesson_id': lessonId.toString(),
          'date': date,
        },
      );
      final lessonDetailResponse = OyunGrubuLessonDetailResponse.fromJson(
        response,
      );
      return Success(lessonDetailResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getLessonDetails failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> submitAttendance({
    required int studentId,
    required String date,
    required String startTime,
    required String status,
    required int lessonId,
    String? note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.submitAttendance,
        body: {
          'user_key': userKey,
          'student_id': studentId.toString(),
          'date': date,
          'start_time': startTime,
          'status': status,
          'lesson_id': lessonId.toString(),
          'note': note ?? '',
        },
      );

      if (response['success'] == 'true' || response['success'] == true) {
        return const Success(true);
      }
      return Failure(response['message']?.toString() ?? 'error_occurred');
    } catch (e) {
      AppLogger.error('OyunGrubu submitAttendance failed', e);
      return Failure(e.toString());
    }
  }
}
