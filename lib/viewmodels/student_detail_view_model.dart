import 'package:flutter/material.dart';
import '../../core/network/api_result.dart';
import '../../models/daily_student_model.dart';
import '../../services/home_service.dart';

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

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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

    if (_isDisposed) return;

    if (result is Success<List<DailyStudentModel>>) {
      _dailyData = result.data;
    } else if (result is Failure<List<DailyStudentModel>>) {
      // "Bulunamadı" is API's way of saying no data found for this day/part.
      // Treat it as empty state instead of error.
      if (result.message == 'Bulunamadı') {
        _dailyData = [];
      } else {
        _errorMessage = result.message;
        _dailyData = [];
      }
    }

    _isLoading = false;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<ApiResult<bool>> saveNote({
    required String content,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null) {
      return Failure('Missing parameters');
    }

    // Find existing note logs if any
    DailyStudentModel? existingNote;
    try {
      existingNote = _dailyData.firstWhere(
        (item) => item.teacherNote != null || item.parentNote != null,
      );
    } catch (e) {
      existingNote = null;
    }

    String teacherNote = existingNote?.teacherNote ?? '';
    String parentNote = existingNote?.parentNote ?? '';
    int teacherStatus = existingNote?.teacherStatus ?? 0;
    int parentStatus = existingNote?.parentStatus ?? 0;

    if (role == 'teacher') {
      teacherNote = content;
      parentStatus = 0;
    } else if (role == 'parent') {
      parentNote = content;
      teacherStatus = 0;
    } else if (role == 'superadmin') {
      // Superadmin logic: If it's a new entry, send 0, otherwise send existing status
      // In this case, we'll assume content goes to teacherNote or we could have
      // a more complex UI for superadmin. For now, following the prompt.
      // prompt says "Superadmin değişiklik yapacağında durumları önceden nasılsa, aynı şekilde gönderilmeli. İlk defa ekleyecekse durumları 0 göndermeli"
      teacherNote = content;
    }

    final result = await _homeService.addDailyStudentsNote(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      teacherNote: teacherNote,
      parentNote: parentNote,
      teacherStatus: teacherStatus,
      parentStatus: parentStatus,
      date: _selectedDate,
    );

    if (result is Success<bool>) {
      _fetchDailyData();
    }

    return result;
  }

  Future<ApiResult<bool>> saveReceiving({
    required String time,
    required String recipient,
    required String note,
    required int status,
    required int userId,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null) {
      return Failure('Missing parameters');
    }

    // Role-based status and permission checks
    int finalStatus = status;

    // "İlk ekleniş sadece parent ve superadmin tarafından yapılabilir ve status mutlaka 0 gönderilmelidir."
    bool exists = _dailyData.any((item) => item.recipient != null);
    if (!exists) {
      if (role != 'parent' && role != 'superadmin') {
        return Failure(
          'İlk ekleme sadece veli veya yönetici tarafından yapılabilir',
        );
      }
      finalStatus = 0; // Forced to 0 on first entry
    }

    final result = await _homeService.addDailyReceiving(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      date: _selectedDate,
      time: time,
      recipient: recipient,
      status: finalStatus,
      userId: userId,
      note: note,
    );

    if (result is Success<bool>) {
      _fetchDailyData();
    }

    return result;
  }

  Future<ApiResult<bool>> saveActivityTitle({
    required String title,
    int? id,
  }) async {
    if (_schoolId == null || _userKey == null) {
      return Failure('Missing parameters');
    }

    return await _homeService.saveActivityTitle(
      schoolId: _schoolId!,
      userKey: _userKey!,
      title: title,
      id: id,
    );
  }

  Future<ApiResult<bool>> saveActivityValue({
    required String value,
    int? id,
  }) async {
    if (_schoolId == null || _userKey == null) {
      return Failure('Missing parameters');
    }

    return await _homeService.saveActivityValue(
      schoolId: _schoolId!,
      userKey: _userKey!,
      value: value,
      id: id,
    );
  }

  void refresh() {
    _fetchDailyData();
  }
}
