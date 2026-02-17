import 'dart:io';
import 'base_view_model.dart';
import '../services/permission_service.dart';
import '../services/home_service.dart';
import '../models/permission_model.dart';
import '../models/permission_control_model.dart';
import '../models/class_model.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';

class PermissionViewModel extends BaseViewModel {
  final PermissionService _permissionService = PermissionService();
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Super admin: İzin listesi
  List<PermissionModel> _permissions = [];
  List<PermissionModel> get permissions => _permissions;

  // Parent: İzin listesi
  List<ParentPermissionModel> _parentPermissions = [];
  List<ParentPermissionModel> get parentPermissions => _parentPermissions;

  // Dosya indirme path'i
  String _permissionsPath = '';
  String get permissionsPath => _permissionsPath;

  // Super admin: İzin kontrol listesi (kimlerin onayladığı)
  List<PermissionControlModel> _permissionControls = [];
  List<PermissionControlModel> get permissionControls => _permissionControls;

  // Sınıf listesi (izin eklerken sınıf seçimi için)
  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  // Seçili sınıflar
  List<ClassModel> _selectedClasses = [];
  List<ClassModel> get selectedClasses => _selectedClasses;

  bool _isPermissionControlLoading = false;
  bool get isPermissionControlLoading => _isPermissionControlLoading;

  // Seçili dosya
  File? _selectedFile;
  File? get selectedFile => _selectedFile;

  void setSelectedFile(File? file) {
    _selectedFile = file;
    notifyListeners();
  }

  /// Sınıf ID'lerinden sınıf isimlerini döner
  String getClassNamesByIds(String? classIdsString) {
    if (classIdsString == null || classIdsString.isEmpty || _classes.isEmpty) {
      return classIdsString ?? '';
    }

    final ids = classIdsString.split(',').map((e) => e.trim()).toList();
    final names = <String>[];

    for (var id in ids) {
      final classModel = _classes.firstWhere(
        (c) => c.id.toString() == id,
        orElse: () => ClassModel(id: -1, name: id),
      );
      if (classModel.id != -1) {
        names.add(classModel.name ?? id);
      } else {
        names.add(id);
      }
    }

    return names.join(', ');
  }

  void toggleClassSelection(ClassModel classModel) {
    if (_selectedClasses.any((c) => c.id == classModel.id)) {
      _selectedClasses.removeWhere((c) => c.id == classModel.id);
    } else {
      _selectedClasses.add(classModel);
    }
    notifyListeners();
  }

  void clearSelectedClasses() {
    _selectedClasses = [];
    notifyListeners();
  }

  /// Sınıfları yükle (izin eklerken kullanılır)
  Future<void> fetchClasses({
    required int schoolId,
    required String userKey,
  }) async {
    final result = await _homeService.getAllClasses(
      schoolId: schoolId,
      userKey: userKey,
    );

    if (result is Success<List<ClassModel>>) {
      _classes = result.data;
      notifyListeners();
    }
  }

  /// Super admin: İzin ekle
  Future<ApiResult<bool>> addPermission({
    required int schoolId,
    required String userKey,
    required String classIds,
    required String title,
    required File file,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _permissionService.addPermission(
      schoolId: schoolId,
      userKey: userKey,
      classIds: classIds,
      title: title,
      file: file,
    );

    if (result is Success) {
      _selectedFile = null;
      _selectedClasses = [];
      await fetchPermissionList(schoolId: schoolId, userKey: userKey);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Super admin: İzin listele
  Future<void> fetchPermissionList({
    required int schoolId,
    required String userKey,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _permissionService.getPermissionList(
      schoolId: schoolId,
      userKey: userKey,
    );

    if (result is Success<Map<String, dynamic>>) {
      final data = result.data;
      _permissions =
          (data['permissions'] as List?)?.cast<PermissionModel>() ?? [];
      _permissionsPath = data['path']?.toString() ?? '';
    } else if (result is Failure<Map<String, dynamic>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Super admin: İzin kontrol (kimlerin onayladığı)
  Future<void> fetchPermissionControl({
    required int schoolId,
    required String userKey,
    required int permissionId,
  }) async {
    _isPermissionControlLoading = true;
    notifyListeners();

    final result = await _permissionService.getPermissionControl(
      schoolId: schoolId,
      userKey: userKey,
      permissionId: permissionId,
    );

    if (result is Success<List<PermissionControlModel>>) {
      _permissionControls = result.data;
    } else if (result is Failure<List<PermissionControlModel>>) {
      _errorMessage = result.message;
      AppLogger.error('Fetch permission control failed', _errorMessage);
    }

    _isPermissionControlLoading = false;
    notifyListeners();
  }

  /// Parent: İzin listele
  Future<void> fetchParentPermissions({
    required int schoolId,
    required String userKey,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _permissionService.getPermissionsParent(
      schoolId: schoolId,
      userKey: userKey,
    );

    if (result is Success<Map<String, dynamic>>) {
      final data = result.data;
      _parentPermissions =
          (data['permissions'] as List?)?.cast<ParentPermissionModel>() ?? [];
      _permissionsPath = data['path']?.toString() ?? '';
    } else if (result is Failure<Map<String, dynamic>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Parent: İzin onayla
  Future<ApiResult<bool>> approvePermission({
    required int schoolId,
    required String userKey,
    required int permissionId,
  }) async {
    final result = await _permissionService.permissionStatusParent(
      schoolId: schoolId,
      userKey: userKey,
      permissionId: permissionId,
    );

    if (result is Success) {
      await fetchParentPermissions(schoolId: schoolId, userKey: userKey);
    }

    return result;
  }

  void refresh({
    required int schoolId,
    required String userKey,
    required String role,
  }) {
    if (role == 'superadmin') {
      fetchPermissionList(schoolId: schoolId, userKey: userKey);
    } else if (role == 'parent') {
      fetchParentPermissions(schoolId: schoolId, userKey: userKey);
    }
  }

  void onRetry({
    required int schoolId,
    required String userKey,
    required String role,
  }) {
    _errorMessage = null;
    refresh(schoolId: schoolId, userKey: userKey, role: role);
  }
}
