import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/student_model.dart';
import '../services/home_service.dart';

class StudentListViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  int? _schoolId;
  int? get schoolId => _schoolId;
  String? _userKey;
  String? get userKey => _userKey;
  int? _classId;

  String _selectedDate = DateTime.now().toString().split(' ')[0];
  String get selectedDate => _selectedDate;

  void init(int schoolId, String userKey, int classId) {
    _schoolId = schoolId;
    _userKey = userKey;
    _classId = classId;
    _fetchStudents();
  }

  void setDate(DateTime date) {
    _selectedDate = date.toString().split(' ')[0];
    notifyListeners();
  }

  Future<void> _fetchStudents() async {
    if (_schoolId == null || _userKey == null || _classId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.getAllStudents(
      schoolId: _schoolId!,
      userKey: _userKey!,
      classId: _classId!,
    );

    if (result is Success<List<StudentModel>>) {
      _students = result.data;
    } else if (result is Failure<List<StudentModel>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    _fetchStudents();
  }
}
