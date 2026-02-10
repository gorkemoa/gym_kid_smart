import 'package:flutter/material.dart';
import '../../core/network/api_result.dart';
import '../../models/daily_student_model.dart';
import '../../services/home_service.dart';
import '../../core/utils/logger.dart'; // Make sure AppLogger is available if needed

class StudentDetailViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DailyStudentModel> _dailyData = [];
  List<DailyStudentModel> get dailyData => _dailyData;

  // Parameters
  int? _schoolId;
  String? _userKey;
  int? _studentId;
  String _selectedDate = DateTime.now().toString().split(' ')[0];
  String _selectedPart = 'meals';

  String get selectedDate => _selectedDate;
  String get selectedPart => _selectedPart;

  void init({
    required int schoolId,
    required String userKey,
    required int studentId,
  }) {
    _schoolId = schoolId;
    _userKey = userKey;
    _studentId = studentId;
    _fetchDailyData();
  }

  void setDate(DateTime date) {
    _selectedDate = date.toString().split(' ')[0];
    _fetchDailyData();
  }

  void setPart(String part) {
    _selectedPart = part;
    _fetchDailyData();
  }

  Future<void> _fetchDailyData() async {
    if (_schoolId == null || _userKey == null || _studentId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.getDailyStudent(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      date: _selectedDate,
      part: _selectedPart,
    );

    if (result is Success<List<DailyStudentModel>>) {
      _dailyData = result.data;
    } else if (result is Failure<List<DailyStudentModel>>) {
      _errorMessage = result.message;
      _dailyData = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    _fetchDailyData();
  }
}
