import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_activity_log_model.dart';
import '../models/oyungrubu_package_model.dart';
import '../models/oyungrubu_student_model.dart';
import '../models/oyungrubu_student_history_response.dart';
import '../services/oyungrubu_student_history_service.dart';

class OyunGrubuStudentHistoryViewModel extends BaseViewModel {
  final OyunGrubuStudentHistoryService _historyService =
      OyunGrubuStudentHistoryService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  // Tab control
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void setTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> init(OyunGrubuStudentModel studentModel) async {
    _student = studentModel;
    notifyListeners();
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    if (_student?.id == null) return;

    _setLoading(true);
    _errorMessage = null;

    final result = await _historyService.getStudentHistory(
      studentId: _student!.id!,
    );

    _setLoading(false);

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

  void onRetry() {
    fetchHistory();
  }

  // Stats helpers
  int get attendedCount =>
      _activityLogs?.where((l) => l.activityType == 'attended').length ?? 0;

  int get absentCount =>
      _activityLogs?.where((l) => l.activityType == 'absent').length ?? 0;

  int get postponeCount =>
      _activityLogs?.where((l) => l.activityType == 'postpone').length ?? 0;

  int get totalLogs => _activityLogs?.length ?? 0;

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
    _selectedTabIndex = 0;
    _errorMessage = null;
    _isLoading = false;
  }
}
