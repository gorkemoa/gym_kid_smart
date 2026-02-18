import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_student_model.dart';
import '../models/oyungrubu_students_response.dart';
import '../models/oyungrubu_user_model.dart';
import '../services/oyungrubu_student_service.dart';
import '../services/oyungrubu_auth_service.dart';

class OyunGrubuHomeViewModel extends BaseViewModel {
  final OyunGrubuStudentService _studentService = OyunGrubuStudentService();
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OyunGrubuStudentModel>? _students;
  List<OyunGrubuStudentModel>? get students => _students;

  OyunGrubuUserModel? _user;
  OyunGrubuUserModel? get user => _user;

  Future<void> init() async {
    _user = await _authService.getSavedUser();
    notifyListeners();
    await fetchStudents();
  }

  void onRetry() {
    fetchStudents();
  }

  void refresh() {
    fetchStudents();
  }

  Future<void> fetchStudents({bool isSilent = false}) async {
    if (!isSilent) {
      _setLoading(true);
      _errorMessage = null;
    }

    final result = await _studentService.getStudents();

    if (!isSilent) {
      _setLoading(false);
    }

    if (result is Success<OyunGrubuStudentsResponse>) {
      _students = result.data.data;
      notifyListeners();
    } else if (result is Failure<OyunGrubuStudentsResponse>) {
      if (!isSilent) {
        _errorMessage = result.message;
      }
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
