import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/oyungrubu_student_history_response.dart';
import '../models/oyungrubu_package_info_response.dart';
import '../models/oyungrubu_attendance_history_response.dart';

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

  Future<ApiResult<bool>> updateStudentProfile({
    required int studentId,
    required String name,
    required String surname,
    required String birthDate,
    String? medications,
    String? allergies,
    File? photo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final Map<String, String> body = {
        'user_key': userKey,
        'student_id': studentId.toString(),
        'name': name,
        'surname': surname,
        'birth_date': birthDate,
        'medications': medications ?? '',
        'allergies': allergies ?? '',
      };

      Map<String, File>? files;
      if (photo != null) {
        files = {'photo': photo};
      }

      final response = await _apiClient.post(
        ApiConstants.updateStudentProfile,
        body: body,
        files: files,
      );

      if (response['success'] != null) {
        return const Success(true);
      }
      return Failure(response['failure'] ?? 'update_failed');
    } catch (e) {
      AppLogger.error('OyunGrubu updateStudentProfile failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuPackageInfoResponse>> getPackageInfo({
    required int studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getPackageInfo,
        body: {
          'user_key': userKey,
          'student_id': studentId.toString(),
        },
      );
      final packageInfoResponse =
          OyunGrubuPackageInfoResponse.fromJson(response);
      return Success(packageInfoResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getPackageInfo failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuAttendanceHistoryResponse>> getAttendanceHistory({
    required int studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getAttendanceHistory,
        body: {
          'user_key': userKey,
          'student_id': studentId.toString(),
        },
      );
      final historyResponse =
          OyunGrubuAttendanceHistoryResponse.fromJson(response);
      return Success(historyResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getAttendanceHistory failed', e);
      return Failure(e.toString());
    }
  }
}
