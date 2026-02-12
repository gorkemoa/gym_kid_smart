import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_result.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../services/home_service.dart';

class StudentListViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  static const String _viewModeKey = 'student_list_view_mode';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  bool _isGridView = false;
  bool get isGridView => _isGridView;

  int? _schoolId;
  int? get schoolId => _schoolId;
  String? _userKey;
  String? get userKey => _userKey;
  int? _classId;
  int? get classId => _classId;

  String _selectedClassName = '';
  String get selectedClassName => _selectedClassName;

  void init(int schoolId, String userKey, int classId) {
    _schoolId = schoolId;
    _userKey = userKey;
    _classId = classId;
    _loadViewMode();
    _fetchClasses();
    _fetchStudents();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool(_viewModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleViewMode() async {
    _isGridView = !_isGridView;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewModeKey, _isGridView);
  }

  Future<void> _fetchClasses() async {
    if (_schoolId == null || _userKey == null) return;

    final result = await _homeService.getAllClasses(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );

    if (result is Success<List<ClassModel>>) {
      _classes = result.data;
      _classes.sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );
      // Set the selected class name
      final current = _classes.where((c) => c.id == _classId).toList();
      if (current.isNotEmpty) {
        _selectedClassName = current.first.name ?? '';
      }
      notifyListeners();
    }
  }

  void switchClass(ClassModel classItem) {
    if (classItem.id == _classId) return;
    _classId = classItem.id;
    _selectedClassName = classItem.name ?? '';
    _students = [];
    notifyListeners();
    _fetchStudents();
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
