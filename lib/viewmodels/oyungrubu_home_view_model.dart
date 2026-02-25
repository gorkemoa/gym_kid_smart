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
import '../models/oyungrubu_lesson_detail_model.dart';
import '../models/oyungrubu_lesson_detail_response.dart';
import '../models/oyungrubu_notification_model.dart';
import '../models/oyungrubu_notifications_response.dart';
import '../services/oyungrubu_student_service.dart';
import '../services/oyungrubu_auth_service.dart';
import '../services/oyungrubu_class_service.dart';
import '../services/oyungrubu_notification_service.dart';

class OyunGrubuHomeViewModel extends BaseViewModel {
  final OyunGrubuStudentService _studentService = OyunGrubuStudentService();
  final OyunGrubuAuthService _authService = OyunGrubuAuthService();
  final OyunGrubuClassService _classService = OyunGrubuClassService();
  final OyunGrubuNotificationService _notificationService =
      OyunGrubuNotificationService();

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
  final Map<int, List<OyunGrubuLessonModel>> _studentHistoryLessonsMap = {};
  List<OyunGrubuLessonModel>? getStudentLessons(int studentId) =>
      _studentLessonsMap[studentId];
  List<OyunGrubuLessonModel>? getStudentHistoryLessons(int studentId) =>
      _studentHistoryLessonsMap[studentId];

  bool _isLessonsLoading = false;
  bool get isLessonsLoading => _isLessonsLoading;
  int? _selectedStudentIdForLessons;
  int? get selectedStudentIdForLessons => _selectedStudentIdForLessons;

  // Notifications
  List<OyunGrubuNotificationModel>? _notifications;
  List<OyunGrubuNotificationModel>? get notifications => _notifications;
  bool _isNotificationsLoading = false;
  bool get isNotificationsLoading => _isNotificationsLoading;

  Future<void> init() async {
    _user = await _authService.getSavedUser();
    notifyListeners();
    _notificationService.updateFCMToken(); // Update FCM Token in background
    await Future.wait([fetchStudents(), fetchClasses(), fetchNotifications()]);
  }

  void onRetry() {
    fetchStudents();
    fetchClasses();
  }

  void refresh() {
    fetchStudents();
    fetchClasses();
    fetchNotifications();
  }

  Future<void> fetchStudents({bool isSilent = false}) async {
    if (!isSilent) {
      _setLoading(true);
      _errorMessage = null;
    }

    final result = await _studentService.getStudents();

    if (result is Success<OyunGrubuStudentsResponse>) {
      _students = result.data.data;
      await fetchAllStudentLessons();
    } else if (result is Failure<OyunGrubuStudentsResponse>) {
      if (!isSilent) {
        _errorMessage = result.message;
      }
    }

    if (!isSilent) {
      _setLoading(false);
    } else {
      notifyListeners();
    }
  }

  Future<void> fetchAllStudentLessons() async {
    if (_students == null || _students!.isEmpty) return;

    _isLessonsLoading = true;
    notifyListeners();

    await Future.wait(
      _students!.map((student) async {
        final studentId = student.id ?? 0;
        if (studentId == 0) return;

        final results = await Future.wait([
          _classService.getUpcomingLessons(studentId: studentId),
          _classService.getLessons(studentId: studentId),
        ]);

        // Upcoming Lessons
        final upcomingResult = results[0];
        if (upcomingResult is Success<OyunGrubuLessonsResponse>) {
          _studentLessonsMap[studentId] = upcomingResult.data.data ?? [];
        } else {
          _studentLessonsMap[studentId] = [];
        }

        // History Lessons
        final historyResult = results[1];
        if (historyResult is Success<OyunGrubuLessonsResponse>) {
          _studentHistoryLessonsMap[studentId] = historyResult.data.data ?? [];
        } else {
          _studentHistoryLessonsMap[studentId] = [];
        }
      }),
    );

    _isLessonsLoading = false;
    notifyListeners();
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

  Future<void> fetchNotifications() async {
    _isNotificationsLoading = true;
    notifyListeners();

    final result = await _notificationService.getNotifications();

    _isNotificationsLoading = false;

    if (result is Success<OyunGrubuNotificationsResponse>) {
      _notifications = result.data.data;
    } else if (result is Failure<OyunGrubuNotificationsResponse>) {
      _notifications = [];
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

    final results = await Future.wait([
      _classService.getUpcomingLessons(studentId: studentId),
      _classService.getLessons(studentId: studentId),
    ]);

    _isLessonsLoading = false;

    // Upcoming Lessons
    final upcomingResult = results[0];
    if (upcomingResult is Success<OyunGrubuLessonsResponse>) {
      _studentLessonsMap[studentId] = upcomingResult.data.data ?? [];
    } else {
      _studentLessonsMap[studentId] = [];
    }

    // History Lessons
    final historyResult = results[1];
    if (historyResult is Success<OyunGrubuLessonsResponse>) {
      _studentHistoryLessonsMap[studentId] = historyResult.data.data ?? [];
    } else {
      _studentHistoryLessonsMap[studentId] = [];
    }

    notifyListeners();
  }

  Future<OyunGrubuLessonDetailModel?> fetchLessonDetails({
    required int studentId,
    required int lessonId,
    required String date,
  }) async {
    final result = await _classService.getLessonDetails(
      studentId: studentId,
      lessonId: lessonId,
      date: date,
    );

    if (result is Success<OyunGrubuLessonDetailResponse>) {
      return result.data.data;
    } else {
      return null;
    }
  }

  Future<bool> submitAttendance({
    required int studentId,
    required String date,
    required String startTime,
    required String status,
    required int lessonId,
    String? note,
  }) async {
    final result = await _classService.submitAttendance(
      studentId: studentId,
      date: date,
      startTime: startTime,
      status: status,
      lessonId: lessonId,
      note: note,
    );

    if (result is Success<bool>) {
      // Refresh lessons silently
      fetchLessonsForStudent(studentId);
      return true;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
