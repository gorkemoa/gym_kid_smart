import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/daily_student_model.dart';
import '../models/student_model.dart';
import '../models/student_medicament_model.dart';
import '../models/meal_menu_model.dart';
import '../services/home_service.dart';

class StudentDetailViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Per-section data
  final Map<String, List<DailyStudentModel>> _allSectionsData = {};
  Map<String, List<DailyStudentModel>> get allSectionsData => _allSectionsData;

  // Per-section loading state
  final Map<String, bool> _sectionLoading = {};
  Map<String, bool> get sectionLoading => _sectionLoading;

  // Expanded sections
  final Set<String> _expandedSections = {};
  Set<String> get expandedSections => _expandedSections;

  // Keep dailyData for backward compat
  List<DailyStudentModel> _dailyData = [];
  List<DailyStudentModel> get dailyData => _dailyData;

  List<StudentMedicamentModel> _medicaments = [];
  List<StudentMedicamentModel> get medicaments => _medicaments;

  List<MealMenuModel> _mealMenus = [];
  List<MealMenuModel> get mealMenus => _mealMenus;

  // Classmates
  List<StudentModel> _classmates = [];
  List<StudentModel> get classmates => _classmates;

  // Parameters
  int? _schoolId;
  String? _userKey;
  int? _studentId;
  int? get studentId => _studentId;
  int? _classId;
  String _selectedDate = DateTime.now().toString().split(' ')[0];
  String _selectedPart = 'meals';

  String get selectedDate => _selectedDate;
  String get selectedPart => _selectedPart;

  static const List<String> allParts = [
    'meals',
    'socials',
    'activities',
    'medicament',
    'receiving',
    'noteLogs',
  ];

  void init({
    required int schoolId,
    required String userKey,
    required int studentId,
    int? classId,
    String? initialDate,
  }) {
    _schoolId = schoolId;
    _userKey = userKey;
    _studentId = studentId;
    _classId = classId;
    if (initialDate != null) {
      _selectedDate = initialDate;
    }
    // Expand meals by default if not already set
    if (_expandedSections.isEmpty) {
      _expandedSections.add('meals');
    }
    _selectedPart = 'meals';

    // Initial fetch for expanded sections
    for (var part in _expandedSections) {
      _fetchSectionData(part);
    }

    _fetchStudentMedicaments();
    if (_classId != null) {
      _fetchClassmates();
    }
  }

  Future<void> _fetchClassmates() async {
    if (_schoolId == null || _userKey == null || _classId == null) return;
    final result = await _homeService.getAllStudents(
      schoolId: _schoolId!,
      userKey: _userKey!,
      classId: _classId!,
    );

    if (result is Success<List<StudentModel>>) {
      _classmates = result.data;
      notifyListeners();
    }
  }

  void switchStudent(int newStudentId) {
    if (newStudentId == _studentId) return;
    _studentId = newStudentId;
    _allSectionsData.clear();
    _medicaments = [];
    for (final part in Set<String>.from(_expandedSections)) {
      _fetchSectionData(part);
    }
    _fetchStudentMedicaments();
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date.toString().split(' ')[0];
    _allSectionsData.clear();
    for (final part in Set<String>.from(_expandedSections)) {
      _fetchSectionData(part);
    }
    notifyListeners();
  }

  void setPart(String part) {
    _selectedPart = part;
    notifyListeners();
  }

  void toggleSection(String part) {
    if (_expandedSections.contains(part)) {
      _expandedSections.remove(part);
    } else {
      _expandedSections.clear();
      _expandedSections.add(part);
      _selectedPart = part;
      if (!_allSectionsData.containsKey(part) ||
          _allSectionsData[part]!.isEmpty) {
        _fetchSectionData(part);
      }
    }
    notifyListeners();
  }

  Future<void> _fetchSectionData(String part, {bool silent = false}) async {
    if (_schoolId == null || _userKey == null || _studentId == null) return;

    if (!silent) {
      _sectionLoading[part] = true;
      notifyListeners();
    }

    final result = await _homeService.getDailyStudent(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      date: _selectedDate,
      part: part,
    );

    if (result is Success<List<DailyStudentModel>>) {
      _allSectionsData[part] = result.data;
      if (part == 'medicament') {
        await _fetchStudentMedicaments();
      }
    } else {
      _allSectionsData[part] = [];
    }

    if (part == _selectedPart) {
      _dailyData = _allSectionsData[part] ?? [];
    }

    _sectionLoading[part] = false;
    notifyListeners();
  }

  Future<void> _fetchStudentMedicaments() async {
    if (_schoolId == null || _userKey == null || _studentId == null) return;
    final result = await _homeService.getStudentMedicament(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
    );

    if (result is Success<List<StudentMedicamentModel>>) {
      _medicaments = result.data;
      notifyListeners();
    }
  }

  Future<ApiResult<bool>> toggleMedicament({
    required int medicamentId,
    required int userId,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null) {
      return Failure('Missing parameters');
    }

    // 1. Optimistic Update
    final medicamentData = List<DailyStudentModel>.from(
      _allSectionsData['medicament'] ?? [],
    );
    final alreadyExistsIdx = medicamentData.indexWhere(
      (d) => d.medicamentId == medicamentId,
    );

    if (alreadyExistsIdx != -1) {
      medicamentData.removeAt(alreadyExistsIdx);
    } else {
      medicamentData.add(
        DailyStudentModel(
          medicamentId: medicamentId,
          dateAdded: DateTime.now().toIso8601String(),
        ),
      );
    }
    _allSectionsData['medicament'] = medicamentData;
    notifyListeners();

    // 2. Execute API Call
    final result = await _homeService.toggleDailyMedicament(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      date: _selectedDate,
      userId: userId,
      medicamentId: medicamentId,
    );

    // 3. Silent refresh to ensure data integrity
    await _fetchSectionData('medicament', silent: true);

    return result;
  }

  Future<ApiResult<bool>> deleteMedicament(int id) async {
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');
    final result = await _homeService.addStudentMedicament(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      name: '',
      time: '',
      note: '',
      status: 0,
      id: id,
    );
    if (result is Success<bool>) {
      _fetchSectionData('medicament');
    }
    return result;
  }

  Future<ApiResult<bool>> saveNote({
    required String content,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');

    final noteData = _allSectionsData['noteLogs'] ?? [];
    DailyStudentModel? existingNote;
    try {
      existingNote = noteData.firstWhere(
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
      _fetchSectionData('noteLogs');
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
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');

    final receivingData = _allSectionsData['receiving'] ?? [];
    bool exists = receivingData.any((item) => item.recipient != null);
    if (!exists && role != 'parent' && role != 'superadmin') {
      return Failure(
        'İlk ekleme sadece veli veya yönetici tarafından yapılabilir',
      );
    }

    final result = await _homeService.addDailyReceiving(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      date: _selectedDate,
      time: time,
      recipient: recipient,
      status: status,
      userId: userId,
      note: note,
    );

    if (result is Success<bool>) {
      _fetchSectionData('receiving');
    }
    return result;
  }

  Future<ApiResult<bool>> deleteDailySocial({
    required String title,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');
    if (role != 'superadmin' && role != 'teacher')
      return Failure('Yetkisiz işlem');
    final result = await _homeService.deleteDailySocial(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      title: title,
      date: _selectedDate,
    );
    if (result is Success<bool>) _fetchSectionData('socials');
    return result;
  }

  Future<ApiResult<bool>> deleteDailyActivity({
    required String title,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');
    if (role != 'superadmin' && role != 'teacher')
      return Failure('Yetkisiz işlem');
    final result = await _homeService.deleteDailyActivity(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      title: title,
      date: _selectedDate,
    );
    if (result is Success<bool>) _fetchSectionData('activities');
    return result;
  }

  Future<ApiResult<bool>> deleteDailyMeal({required String title}) async {
    if (_schoolId == null || _userKey == null || _studentId == null)
      return Failure('Missing parameters');
    final result = await _homeService.deleteDailyMeal(
      schoolId: _schoolId!,
      userKey: _userKey!,
      studentId: _studentId!,
      title: title,
      date: _selectedDate,
    );
    if (result is Success<bool>) _fetchSectionData('meals');
    return result;
  }

  void refresh() {
    for (final part in _expandedSections) {
      _fetchSectionData(part, silent: true);
    }
    _fetchStudentMedicaments();
  }
}
