import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/daily_student_model.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/activity_value_model.dart';
import '../models/activity_title_model.dart';
import '../services/home_service.dart';

class StudentEntryViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  late UserModel user;
  late StudentModel student;
  late String categoryId;
  late String date;
  DailyStudentModel? existingData;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List<ActivityValueModel> _activityValues = [];
  List<ActivityValueModel> get activityValues => _activityValues;

  List<ActivityTitleModel> _activityTitles = [];
  List<ActivityTitleModel> get activityTitles => _activityTitles;

  String? _selectedActivityValue;
  String? get selectedActivityValue => _selectedActivityValue;

  int _receivingStatus = 0;
  int get receivingStatus => _receivingStatus;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  void init({
    required UserModel user,
    required StudentModel student,
    required String categoryId,
    required String date,
    DailyStudentModel? existingData,
  }) {
    this.user = user;
    this.student = student;
    this.categoryId = categoryId;
    this.date = date;
    this.existingData = existingData;

    if (categoryId == 'receiving') {
      recipientController.text = existingData?.recipient ?? '';
      timeController.text =
          existingData?.time ??
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
      noteController.text = existingData?.note ?? '';
      _receivingStatus = existingData?.status ?? 0;
    } else if (categoryId == 'activities') {
      titleController.text = existingData?.title ?? '';
      _selectedActivityValue = existingData?.value;
      valueController.text = existingData?.value ?? '';
      noteController.text = existingData?.note ?? '';
      _fetchActivityValues();
      _fetchActivityTitles();
    } else if (categoryId == 'noteLogs') {
      if (user.role == 'teacher') {
        noteController.text = existingData?.teacherNote ?? '';
      } else if (user.role == 'parent') {
        noteController.text = existingData?.parentNote ?? '';
      } else {
        noteController.text = existingData?.teacherNote ?? '';
      }
    }
  }

  void setReceivingStatus(int status) {
    _receivingStatus = status;
    notifyListeners();
  }

  void setSelectedActivityValue(String? value) {
    _selectedActivityValue = value;
    if (value != null) {
      valueController.text = value;
    }
    notifyListeners();
  }

  void setTitle(String title) {
    titleController.text = title;
    notifyListeners();
  }

  Future<void> _fetchActivityTitles() async {
    final result = await _homeService.getAllActivitiesTitle(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );
    if (result is Success<List<ActivityTitleModel>>) {
      _activityTitles = result.data;
      notifyListeners();
    }
  }

  Future<void> _fetchActivityValues() async {
    final result = await _homeService.getAllActivitiesValue(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
    );
    if (result is Success<List<ActivityValueModel>>) {
      _activityValues = result.data;
      notifyListeners();
    }
  }

  Future<ApiResult<bool>> save() async {
    _isSaving = true;
    notifyListeners();

    ApiResult<bool> result;

    if (categoryId == 'receiving') {
      result = await _saveReceiving();
    } else if (categoryId == 'activities') {
      result = await _saveActivity();
    } else if (categoryId == 'noteLogs') {
      result = await _saveNote();
    } else {
      result = Failure('Unsupported category');
    }

    _isSaving = false;
    notifyListeners();
    return result;
  }

  Future<ApiResult<bool>> saveValueAsTemplate(String value) async {
    if (value.isEmpty) return Failure('Puan/Değer boş olamaz');
    final result = await _homeService.saveActivityValue(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      value: value,
    );
    if (result is Success) {
      await _fetchActivityValues();
    }
    return result;
  }

  Future<ApiResult<bool>> saveTitleAsTemplate() async {
    if (titleController.text.isEmpty) return Failure('Başlık boş olamaz');
    return await _homeService.saveActivityTitle(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      title: titleController.text,
    );
  }

  Future<ApiResult<bool>> _saveReceiving() async {
    int finalStatus = _receivingStatus;

    // First entry constraints
    bool exists = existingData != null;
    if (!exists) {
      if (user.role != 'parent' && user.role != 'superadmin') {
        return Failure(
          'İlk ekleme sadece veli veya yönetici tarafından yapılabilir',
        );
      }
      finalStatus = 0;
    }

    return await _homeService.addDailyReceiving(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      studentId: student.id!,
      date: date,
      time: timeController.text,
      recipient: recipientController.text,
      status: finalStatus,
      userId: user.id ?? 0,
      note: noteController.text,
    );
  }

  Future<ApiResult<bool>> _saveActivity() async {
    if (user.role != 'teacher' && user.role != 'superadmin') {
      return Failure('Sadece öğretmen veya yönetici aktivite ekleyebilir');
    }

    return await _homeService.addDailyActivity(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      studentId: student.id!,
      title: titleController.text,
      value: valueController.text,
      note: noteController.text,
      date: date,
      userId: user.id ?? 0,
    );
  }

  Future<ApiResult<bool>> _saveNote() async {
    String teacherNote = existingData?.teacherNote ?? '';
    String parentNote = existingData?.parentNote ?? '';
    int teacherStatus = existingData?.teacherStatus ?? 0;
    int parentStatus = existingData?.parentStatus ?? 0;

    if (user.role == 'teacher') {
      teacherNote = noteController.text;
      parentStatus = 0;
    } else if (user.role == 'parent') {
      parentNote = noteController.text;
      teacherStatus = 0;
    } else if (user.role == 'superadmin') {
      teacherNote = noteController.text;
    }

    return await _homeService.addDailyStudentsNote(
      schoolId: user.schoolId ?? 1,
      userKey: user.userKey ?? '',
      studentId: student.id!,
      teacherNote: teacherNote,
      parentNote: parentNote,
      teacherStatus: teacherStatus,
      parentStatus: parentStatus,
      date: date,
    );
  }

  @override
  void dispose() {
    recipientController.dispose();
    titleController.dispose();
    valueController.dispose();
    timeController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
