import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/notice_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../services/home_service.dart';
import '../core/utils/logger.dart';

class NoticeViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<NoticeModel> _notices = [];
  List<NoticeModel> get notices => _notices;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  ClassModel? _selectedClass;
  ClassModel? get selectedClass => _selectedClass;

  UserModel? _user;
  List<StudentModel> _students = [];

  Future<void> init(UserModel user) async {
    _user = user;
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_user!.role == 'admin' ||
          _user!.role == 'teacher' ||
          _user!.role == 'superadmin') {
        await _fetchClasses();
        // Initially load all notices (id 0)
        await fetchNotices(0);
      } else if (_user!.role == 'parent') {
        await _fetchParentStudents();
        if (_students.length == 1) {
          // Auto load student's class
          await fetchNotices(_students.first.classId ?? 0);
        } else if (_students.isNotEmpty) {
          // Multiple students, let them select or default to first
          await fetchNotices(_students.first.classId ?? 0);
        } else {
          await fetchNotices(0);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Notice init failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchClasses() async {
    final result = await _homeService.getAllClasses(
      schoolId: _user!.schoolId ?? 1,
      userKey: _user!.userKey ?? '',
    );
    if (result is Success<List<ClassModel>>) {
      _classes = result.data
        ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    }
  }

  Future<void> _fetchParentStudents() async {
    final result = await _homeService.getAllStudents(
      schoolId: _user!.schoolId ?? 1,
      userKey: _user!.userKey ?? '',
    );
    if (result is Success<List<StudentModel>>) {
      _students = result.data;
    }
  }

  Future<void> fetchNotices(int classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.getAllNotices(
      schoolId: _user!.schoolId ?? 1,
      userKey: _user!.userKey ?? '',
      classId: classId,
    );

    if (result is Success<List<NoticeModel>>) {
      _notices = result.data;
      // Sort by date descending
      _notices.sort((a, b) {
        final dateA = DateTime.tryParse(a.noticeDate ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b.noticeDate ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });
    } else if (result is Failure<List<NoticeModel>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectClass(ClassModel? classItem) {
    _selectedClass = classItem;
    fetchNotices(classItem?.id ?? 0);
  }

  void onRetry() {
    if (_user != null) init(_user!);
  }

  Future<void> refresh() async {
    if (_user != null) {
      await fetchNotices(_selectedClass?.id ?? 0);
    }
  }
}
