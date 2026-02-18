import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_student_model.dart';
import '../models/oyungrubu_students_response.dart';
import '../models/oyungrubu_user_model.dart';
import '../models/oyungrubu_class_model.dart';
import '../models/oyungrubu_classes_response.dart';
import '../models/oyungrubu_timetable_model.dart';
import '../models/oyungrubu_timetable_response.dart';
import '../models/oyungrubu_lesson_model.dart';
import '../models/oyungrubu_lessons_response.dart';
import '../services/oyungrubu_student_service.dart';
import '../services/oyungrubu_auth_service.dart';
import '../services/oyungrubu_class_service.dart';

class OyunGrubuHomeViewModel extends BaseViewModel {
  final OyunGrubuStudentService _studentService = OyunGrubuStudentService();
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();
  final OyunGrubuClassService _classService = OyunGrubuClassService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OyunGrubuStudentModel>? _students;
  List<OyunGrubuStudentModel>? get students => _students;

  OyunGrubuUserModel? _user;
  OyunGrubuUserModel? get user => _user;

  // Classes
  List<OyunGrubuClassModel>? _classes;
  List<OyunGrubuClassModel>? get classes => _classes;
  bool _isClassesLoading = false;
  bool get isClassesLoading => _isClassesLoading;

  // Selected class timetable
  OyunGrubuClassModel? _selectedClass;
  OyunGrubuClassModel? get selectedClass => _selectedClass;
  List<OyunGrubuTimetableModel>? _timetable;
  List<OyunGrubuTimetableModel>? get timetable => _timetable;
  bool _isTimetableLoading = false;
  bool get isTimetableLoading => _isTimetableLoading;

  // Student lessons
  final Map<int, List<OyunGrubuLessonModel>> _studentLessonsMap = {};
  List<OyunGrubuLessonModel>? getStudentLessons(int studentId) =>
      _studentLessonsMap[studentId];
  bool _isLessonsLoading = false;
  bool get isLessonsLoading => _isLessonsLoading;
  int? _selectedStudentIdForLessons;
  int? get selectedStudentIdForLessons => _selectedStudentIdForLessons;

  Future<void> init() async {
    _user = await _authService.getSavedUser();
    notifyListeners();
    await Future.wait([fetchStudents(), fetchClasses()]);
  }

  void onRetry() {
    fetchStudents();
    fetchClasses();
  }

  void refresh() {
    fetchStudents();
    fetchClasses();
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

  Future<void> fetchClasses() async {
    _isClassesLoading = true;
    notifyListeners();

    final result = await _classService.getClasses();

    _isClassesLoading = false;

    if (result is Success<OyunGrubuClassesResponse>) {
      _classes = result.data.data;
    } else if (result is Failure<OyunGrubuClassesResponse>) {
      _classes = [];
    }
    notifyListeners();
  }

  Future<void> selectClassAndFetchTimetable(
    OyunGrubuClassModel classItem,
  ) async {
    _selectedClass = classItem;
    _isTimetableLoading = true;
    notifyListeners();

    final result = await _classService.getTimeTable(classId: classItem.id!);

    _isTimetableLoading = false;

    if (result is Success<OyunGrubuTimetableResponse>) {
      _timetable = result.data.data;
    } else if (result is Failure<OyunGrubuTimetableResponse>) {
      _timetable = [];
    }
    notifyListeners();
  }

  void clearSelectedClass() {
    _selectedClass = null;
    _timetable = null;
    notifyListeners();
  }

  Future<void> fetchLessonsForStudent(int studentId) async {
    _selectedStudentIdForLessons = studentId;
    _isLessonsLoading = true;
    notifyListeners();

    final result = await _classService.getLessons(studentId: studentId);

    _isLessonsLoading = false;

    if (result is Success<OyunGrubuLessonsResponse>) {
      _studentLessonsMap[studentId] = result.data.data ?? [];
    } else if (result is Failure<OyunGrubuLessonsResponse>) {
      _studentLessonsMap[studentId] = [];
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
