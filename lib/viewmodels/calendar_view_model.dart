import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/calendar_detail_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/home_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CalendarDetailModel? _data;
  CalendarDetailModel? get data => _data;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  ClassModel? _selectedClass;
  ClassModel? get selectedClass => _selectedClass;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  UserModel? _user;

  Future<void> init(UserModel user) async {
    _user = user;
    if (_user == null) return;

    await _fetchAllClasses();
  }

  Future<void> _fetchAllClasses() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _homeService.getAllClasses(
        schoolId: _user?.schoolId ?? 1,
        userKey: _user?.userKey ?? '',
      );

      if (result is Success<List<ClassModel>>) {
        _classes = result.data;
        if (_classes.isNotEmpty) {
          _selectedClass = _classes.first;
          await _fetchCalendarDetail();
        } else {
          _errorMessage = "Sınıf bilgisi bulunamadı.";
          _setLoading(false);
        }
      } else if (result is Failure<List<ClassModel>>) {
        _errorMessage = result.message;
        _setLoading(false);
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Fetch classes failed', e);
      _setLoading(false);
    }
  }

  Future<void> _fetchCalendarDetail() async {
    if (_user == null || _selectedClass == null) {
      _setLoading(false);
      return;
    }

    // Ensure loading is true
    if (!_isLoading) _setLoading(true);

    _errorMessage = null;

    // Note: We might want to clear _data or keep it while loading new data.
    // Given the requirement for "Dynamic Design", keeping it might be better,
    // but usually cleaner to clear or just show loading overlay.
    // I'll keep _data but use _isLoading to show progress.

    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.getCalendarDetail(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        date: dateStr,
        classId: _selectedClass!.id ?? 0,
      );

      if (result is Success<CalendarDetailModel>) {
        _data = result.data;
      } else if (result is Failure<CalendarDetailModel>) {
        _errorMessage = result.message;
        _data = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _data = null;
      AppLogger.error('Fetch calendar detail failed', e);
    } finally {
      _setLoading(false);
    }
  }

  void onClassSelected(ClassModel? classItem) {
    if (classItem == null || classItem.id == _selectedClass?.id) return;
    _selectedClass = classItem;
    notifyListeners();
    _fetchCalendarDetail();
  }

  void onDateSelected(DateTime date) {
    if (date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day)
      return;

    _selectedDate = date;
    notifyListeners();
    _fetchCalendarDetail();
  }

  void refresh() {
    if (_classes.isEmpty) {
      _fetchAllClasses();
    } else {
      _fetchCalendarDetail();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
