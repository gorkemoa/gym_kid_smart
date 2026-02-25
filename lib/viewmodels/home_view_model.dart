import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/notice_model.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/home_service.dart';
import '../services/push_notification_service.dart';
import '../core/utils/logger.dart';

class HomeViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<NoticeModel> _notices = [];
  List<NoticeModel> get notices => _notices;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  int? _classId;
  int? get classId => _classId;

  UserModel? _user;

  Future<void> init(UserModel user) async {
    _user = user;

    // Uygulama her açıldığında veya home yüklendiğinde token güncelleyelim
    final pushService = PushNotificationService();
    pushService.addToken(
      schoolId: _user!.schoolId ?? 1,
      userKey: _user!.userKey ?? '',
    );

    await refresh();
  }

  Future<void> refresh() async {
    if (_user == null) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      int activeClassId = 0;

      // Eğer yönetici değilse (öğretmen veya veli), class_id'yi öğrencilerden al
      if (_user!.role != 'admin') {
        final studentResult = await _homeService.getAllStudents(
          schoolId: _user!.schoolId ?? 1,
          userKey: _user!.userKey ?? '',
        );

        if (studentResult is Success<List<StudentModel>>) {
          _students = studentResult.data;
          if (_students.isNotEmpty) {
            // İlk öğrencinin class_id'sini kullanıyoruz (Mantıksal kabule göre)
            activeClassId = _students.first.classId ?? 0;
            _classId = activeClassId;
          }
        } else if (studentResult is Failure<List<StudentModel>>) {
          AppLogger.warning('Students fetch failed: ${studentResult.message}');
          // Öğrenci çekilemezse devam edebiliriz ama classId 0 kalır
        }
      } else {
        _classId = 0;
      }

      // Duyuruları getir
      final noticeResult = await _homeService.getAllNotices(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        classId: activeClassId,
      );

      if (noticeResult is Success<List<NoticeModel>>) {
        final List<NoticeModel> noticeList = noticeResult.data;
        // Duyuruları yeniden eskiye sıralama (noticeDate'e göre)
        noticeList.sort((a, b) {
          final dateA = a.noticeDate != null
              ? DateTime.tryParse(a.noticeDate!)
              : null;
          final dateB = b.noticeDate != null
              ? DateTime.tryParse(b.noticeDate!)
              : null;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          return dateB.compareTo(dateA); // Yeniden eskiye
        });
        _notices = noticeList.where((n) => n.status != 0).toList();
      } else if (noticeResult is Failure<List<NoticeModel>>) {
        _errorMessage = noticeResult.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Home refresh failed', e);
    } finally {
      _setLoading(false);
    }
  }

  void onRetry() {
    refresh();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
