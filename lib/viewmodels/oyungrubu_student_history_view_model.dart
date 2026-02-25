import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_activity_log_model.dart';
import '../models/oyungrubu_package_model.dart';
import '../models/oyungrubu_package_info_model.dart';
import '../models/oyungrubu_package_info_response.dart';
import '../models/oyungrubu_student_model.dart';
import '../models/oyungrubu_student_history_response.dart';
import '../models/oyungrubu_attendance_history_response.dart';
import '../models/iyzico_package_model.dart';
import '../models/iyzico_packages_response.dart';
import '../services/oyungrubu_student_history_service.dart';

class OyunGrubuStudentHistoryViewModel extends BaseViewModel {
  final OyunGrubuStudentHistoryService _historyService =
      OyunGrubuStudentHistoryService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  bool _isLoadingPackages = false;
  bool get isLoadingPackages => _isLoadingPackages;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OyunGrubuStudentModel? _student;
  OyunGrubuStudentModel? get student => _student;

  List<OyunGrubuActivityLogModel>? _activityLogs;
  List<OyunGrubuActivityLogModel>? get activityLogs => _activityLogs;

  List<OyunGrubuPackageModel>? _activePackages;
  List<OyunGrubuPackageModel>? get activePackages => _activePackages;

  List<OyunGrubuPackageModel>? _expiredPackages;
  List<OyunGrubuPackageModel>? get expiredPackages => _expiredPackages;

  List<OyunGrubuPackageModel>? _allPackages;
  List<OyunGrubuPackageModel>? get allPackages => _allPackages;

  // Attendance history (GetAttendanceHistory API)
  List<OyunGrubuActivityLogModel>? _attendanceHistory;
  List<OyunGrubuActivityLogModel>? get attendanceHistory => _attendanceHistory;

  // Package info
  List<OyunGrubuPackageInfoModel>? _packageInfoList;
  List<OyunGrubuPackageInfoModel>? get packageInfoList => _packageInfoList;

  int _packageCount = 0;
  int get packageCount => _packageCount;

  int _makeupBalance = 0;
  int get makeupBalance => _makeupBalance;

  List<IyzicoPackageModel>? _iyzicoPackages;
  List<IyzicoPackageModel>? get iyzicoPackages => _iyzicoPackages;

  // Edit controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController medicationsController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();

  // Tab control
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> init(OyunGrubuStudentModel studentModel) async {
    _student = studentModel;
    _populateControllers();
    notifyListeners();
    await Future.wait([
      fetchHistory(),
      fetchPackageInfo(),
      fetchAttendanceHistory(),
    ]);
  }

  void _populateControllers() {
    nameController.text = _student?.name ?? '';
    surnameController.text = _student?.surname ?? '';
    birthDateController.text = _student?.birthDate ?? '';
    medicationsController.text = _student?.medications ?? '';
    allergiesController.text = _student?.allergies ?? '';
  }

  Future<void> fetchHistory({bool isSilent = false}) async {
    if (_student?.id == null) return;

    if (!isSilent) {
      _setLoading(true);
      _errorMessage = null;
    }

    final result = await _historyService.getStudentHistory(
      studentId: _student!.id!,
    );

    if (!isSilent) {
      _setLoading(false);
    }

    if (result is Success<OyunGrubuStudentHistoryResponse>) {
      _activityLogs = result.data.activityLogs;
      _activePackages = result.data.activePackages;
      _expiredPackages = result.data.expiredPackages;
      _allPackages = result.data.allPackages;
      notifyListeners();
    } else if (result is Failure<OyunGrubuStudentHistoryResponse>) {
      _errorMessage = result.message;
      notifyListeners();
    }
  }

  Future<bool> updateStudentProfile({File? photo}) async {
    if (_student?.id == null) return false;

    _isUpdating = true;
    notifyListeners();

    final result = await _historyService.updateStudentProfile(
      studentId: _student!.id!,
      name: nameController.text,
      surname: surnameController.text,
      birthDate: birthDateController.text,
      medications: medicationsController.text,
      allergies: allergiesController.text,
      photo: photo,
    );

    _isUpdating = false;
    notifyListeners();

    if (result is Success<bool>) {
      // Update local student model
      _student = OyunGrubuStudentModel(
        id: _student!.id,
        groupId: _student!.groupId,
        name: nameController.text,
        surname: surnameController.text,
        birthDate: birthDateController.text,
        gender: _student!.gender,
        parentId: _student!.parentId,
        photo: _student!.photo,
        status: _student!.status,
        createdAt: _student!.createdAt,
        medications: medicationsController.text,
        allergies: allergiesController.text,
        groupName: _student!.groupName,
      );

      // Silent refresh to update logs and packages
      fetchHistory(isSilent: true);
      fetchAttendanceHistory(isSilent: true);

      notifyListeners();
      return true;
    } else if (result is Failure<bool>) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<File?> pickPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  void onRetry() {
    fetchHistory();
    fetchPackageInfo();
    fetchAttendanceHistory();
  }

  Future<void> fetchPackageInfo({bool isSilent = false}) async {
    if (_student?.id == null) return;

    final result = await _historyService.getPackageInfo(
      studentId: _student!.id!,
    );

    if (result is Success<OyunGrubuPackageInfoResponse>) {
      _packageInfoList = result.data.packages;
      _packageCount = result.data.packageCount ?? 0;
      _makeupBalance = result.data.makeupBalance ?? 0;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceHistory({bool isSilent = false}) async {
    if (_student?.id == null) return;

    final result = await _historyService.getAttendanceHistory(
      studentId: _student!.id!,
    );

    if (result is Success<OyunGrubuAttendanceHistoryResponse>) {
      _attendanceHistory = result.data.data;
      notifyListeners();
    }
  }

  Future<void> fetchIyzicoPackages() async {
    _isLoadingPackages = true;
    _iyzicoPackages = null;
    notifyListeners();

    final result = await _historyService.getIyzicoPackages();

    _isLoadingPackages = false;

    if (result is Success<IyzicoPackagesResponse>) {
      _iyzicoPackages = result.data.data;
    } else if (result is Failure<IyzicoPackagesResponse>) {
      _errorMessage = result.message;
    }
    notifyListeners();
  }

  // Stats helpers — use attendanceHistory if available, fallback to activityLogs
  List<OyunGrubuActivityLogModel>? get _statsSource =>
      _attendanceHistory ?? _activityLogs;

  int get attendedCount =>
      _statsSource?.where((l) => l.activityType == 'attended').length ?? 0;

  int get absentCount =>
      _statsSource?.where((l) => l.activityType == 'absent').length ?? 0;

  int get postponeCount =>
      _statsSource?.where((l) => l.activityType == 'postpone').length ?? 0;

  int get totalLogs => _statsSource?.length ?? 0;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() {
    _student = null;
    _activityLogs = null;
    _activePackages = null;
    _expiredPackages = null;
    _allPackages = null;
    _attendanceHistory = null;
    _packageInfoList = null;
    _packageCount = 0;
    _makeupBalance = 0;
    _selectedTabIndex = 0;
    _errorMessage = null;
    _isLoading = false;
    _isUpdating = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    birthDateController.dispose();
    medicationsController.dispose();
    allergiesController.dispose();
    super.dispose();
  }
}
