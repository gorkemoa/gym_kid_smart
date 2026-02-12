import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/notice_model.dart';
import '../models/user_model.dart';
import '../services/home_service.dart';

class NoticeFormViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  NoticeModel? _notice;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int _status = 1;
  int get status => _status;

  int? _selectedClassId;
  int? get selectedClassId => _selectedClassId;

  void init(UserModel user, {NoticeModel? notice, int? initialClassId}) {
    _user = user;
    _notice = notice;
    _selectedClassId = initialClassId;

    if (_notice != null) {
      titleController.text = _notice!.title ?? '';
      descriptionController.text = _notice!.description ?? '';
      _selectedDate =
          DateTime.tryParse(_notice!.noticeDate ?? '') ?? DateTime.now();
      _status = _notice!.status ?? 1;
      _selectedClassId = _notice!.classId;
    }
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStatus(int status) {
    _status = status;
    notifyListeners();
  }

  void setClassId(int? classId) {
    _selectedClassId = classId;
    notifyListeners();
  }

  Future<bool> saveNotice() async {
    if (_user == null) return false;
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      _errorMessage = 'Title and description are required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.saveNotice(
      schoolId: _user!.schoolId ?? 1,
      userKey: _user!.userKey ?? '',
      classId: _selectedClassId ?? 0,
      title: titleController.text,
      description: descriptionController.text,
      date:
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      status: _status,
      id: _notice?.id ?? 0,
      userId: _user!.id ?? 0,
    );

    _isLoading = false;
    if (result is Success<bool>) {
      notifyListeners();
      return true;
    } else if (result is Failure<bool>) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
