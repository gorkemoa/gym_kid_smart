import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_login_response.dart';
import '../models/oyungrubu_user_model.dart';
import '../models/oyungrubu_profile_response.dart';
import '../core/utils/logger.dart';

class OyunGrubuAuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResult<OyunGrubuLoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );
      final loginResponse = OyunGrubuLoginResponse.fromJson(response);
      if (loginResponse.data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'oyungrubu_user_role',
          loginResponse.data!.role ?? '',
        );
        await prefs.setString(
          'oyungrubu_user_data',
          jsonEncode(loginResponse.data!.toJson()),
        );
        // user_key'i de saklayalım profile isteği için
        await prefs.setString(
          'oyungrubu_user_key',
          loginResponse.data!.userKey ?? '',
        );
      }
      return Success(loginResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu login failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<OyunGrubuProfileResponse>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.getProfile,
        body: {'user_key': userKey},
      );
      final profileResponse = OyunGrubuProfileResponse.fromJson(response);
      return Success(profileResponse);
    } catch (e) {
      AppLogger.error('OyunGrubu getProfile failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> updateParentProfile({
    required String name,
    required String surname,
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final response = await _apiClient.post(
        ApiConstants.updateParentProfile,
        body: {
          'user_key': userKey,
          'name': name,
          'surname': surname,
          'phone': phone,
        },
      );

      if (response['success'] != null) {
        // Profil başarıyla güncellendi, lokal veriyi de güncelleyebiliriz
        final savedUserJson = prefs.getString('oyungrubu_user_data');
        if (savedUserJson != null) {
          final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
          userMap['name'] = name;
          userMap['surname'] = surname;
          userMap['phone'] = phone; // although not in model field by default, we can save it in json
          await prefs.setString('oyungrubu_user_data', jsonEncode(userMap));
        }
        return const Success(true);
      }
      return Failure(response['failure'] ?? 'update_failed');
    } catch (e) {
      AppLogger.error('OyunGrubu updateParentProfile failed', e);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> updateProfileImage({
    required File image,
    required String type, // 'student' or 'parent'
    String? studentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString('oyungrubu_user_key');

      if (userKey == null) {
        return const Failure('no_credentials');
      }

      final Map<String, String> body = {
        'user_key': userKey,
        'type': type,
      };

      if (studentId != null) {
        body['student_id'] = studentId;
      }

      final response = await _apiClient.post(
        ApiConstants.updateProfileImage,
        body: body,
        files: {'image': image},
      );

      if (response['success'] != null) {
        return const Success(true);
      }
      return Failure(response['failure'] ?? 'upload_failed');
    } catch (e) {
      AppLogger.error('OyunGrubu updateProfileImage failed', e);
      return Failure(e.toString());
    }
  }

  Future<OyunGrubuUserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('oyungrubu_user_data');
    if (userData != null) {
      return OyunGrubuUserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('oyungrubu_user_data');
    await prefs.remove('oyungrubu_user_role');
    await prefs.remove('oyungrubu_user_key');
  }
}
