import 'dart:io';
import '../app/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/permission_model.dart';
import '../models/permission_control_model.dart';

class PermissionService {
  final ApiClient _apiClient = ApiClient();

  /// Super admin: İzin ekleme (dosya yüklemeli - sadece docx/pdf)
  Future<ApiResult<bool>> addPermission({
    required int schoolId,
    required String userKey,
    required String classIds,
    required String title,
    required File file,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.addPermission,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'class_ids': classIds,
          'title': title,
        },
        files: {'file': file},
      );

      if (response['success'] != null || response['data'] == true) {
        return const Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'İzin eklenemedi',
      );
    } catch (e) {
      AppLogger.error('Add permission failed', e);
      return Failure(e.toString());
    }
  }

  /// Parent: Kendisine ait izin başlıklarını listeler
  /// API yanıtı: { data: { permissions: [{permissionItem: {...}, status: 0}], path: "..." } }
  Future<ApiResult<Map<String, dynamic>>> getPermissionsParent({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getPermissionsParent,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final permissionsList = data['permissions'];
        final path = data['path']?.toString() ?? '';

        if (permissionsList != null && permissionsList is List) {
          final permissions = permissionsList
              .map((json) => ParentPermissionModel.fromJson(json))
              .toList();
          return Success({'permissions': permissions, 'path': path});
        }
      }
      return const Success({'permissions': [], 'path': ''});
    } catch (e) {
      if (e.toString().contains('Bulunamadı') ||
          e.toString().contains('Hata')) {
        return const Success({'permissions': [], 'path': ''});
      }
      AppLogger.error('Fetch permissions parent failed', e);
      return Failure(e.toString());
    }
  }

  /// Parent: Seçtiği izni onaylar
  Future<ApiResult<bool>> permissionStatusParent({
    required int schoolId,
    required String userKey,
    required int permissionId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.permissionStatusParent,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'permission_id': permissionId,
        },
      );

      if (response['success'] != null || response['data'] == true) {
        return const Success(true);
      }
      return Failure(
        response['message'] ?? response['failure'] ?? 'İzin onaylanamadı',
      );
    } catch (e) {
      AppLogger.error('Permission status parent failed', e);
      return Failure(e.toString());
    }
  }

  /// Super admin: İzin başlıklarını listeler
  /// API yanıtı: { data: { list: [{...}], path: "..." } }
  Future<ApiResult<Map<String, dynamic>>> getPermissionList({
    required int schoolId,
    required String userKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.permissionList,
        body: {'school_id': schoolId, 'user_key': userKey},
      );

      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final list = data['list'];
        final path = data['path']?.toString() ?? '';

        if (list != null && list is List) {
          final permissions = list
              .map((json) => PermissionModel.fromJson(json))
              .toList();
          return Success({'permissions': permissions, 'path': path});
        }
      }
      return const Success({'permissions': [], 'path': ''});
    } catch (e) {
      if (e.toString().contains('Bulunamadı') ||
          e.toString().contains('Hata')) {
        return const Success({'permissions': [], 'path': ''});
      }
      AppLogger.error('Fetch permission list failed', e);
      return Failure(e.toString());
    }
  }

  /// Super admin: İzin başlığını kimlerin onayladığını listeler
  Future<ApiResult<List<PermissionControlModel>>> getPermissionControl({
    required int schoolId,
    required String userKey,
    required int permissionId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.permissionControl,
        body: {
          'school_id': schoolId,
          'user_key': userKey,
          'permission_id': permissionId,
        },
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        final controls = data
            .map((json) => PermissionControlModel.fromJson(json))
            .toList();
        return Success(controls);
      }
      return const Success([]);
    } catch (e) {
      if (e.toString().contains('Bulunamadı') ||
          e.toString().contains('Hata')) {
        return const Success([]);
      }
      AppLogger.error('Fetch permission control failed', e);
      return Failure(e.toString());
    }
  }
}
