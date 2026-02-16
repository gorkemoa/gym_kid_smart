import 'dart:io';
import 'base_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../core/network/api_result.dart';
import '../core/utils/logger.dart';
import '../models/calendar_detail_model.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';
import '../services/home_service.dart';

class CalendarViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CalendarDetailModel? _data;
  CalendarDetailModel? get data => _data;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  List<LessonModel> _lessons = [];
  List<LessonModel> get lessons => _lessons;

  ClassModel? _selectedClass;
  ClassModel? get selectedClass => _selectedClass;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  UserModel? _user;

  Future<void> init(UserModel user) async {
    _user = user;
    if (_user == null) return;

    await _fetchAllClasses();
    await fetchLessons();
  }

  Future<void> fetchLessons() async {
    if (_user == null) return;
    try {
      final result = await _homeService.getAllLessons(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
      );
      if (result is Success<List<LessonModel>>) {
        _lessons = result.data;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Fetch lessons failed', e);
    }
  }

  Future<bool> addTimeTable({
    required int lessonId,
    required String description,
    required String startTime,
    required String endTime,
    File? file,
  }) async {
    if (_user == null || _selectedClass == null) return false;

    // Check permissions
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.addDailyTimeTable(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        classId: _selectedClass!.id ?? 0,
        lessonId: lessonId,
        description: description,
        date: dateStr,
        startTime: startTime,
        endTime: endTime,
        userId: _user!.id ?? 0,
        file: file,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Add time table failed', e);
      _setLoading(false);
      return false;
    }
    return false;
  }

  Future<bool> deleteTimeTableEntry({required int lessonId}) async {
    if (_user == null || _selectedClass == null) return false;

    // Check permissions
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.deleteTimeTable(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        classId: _selectedClass!.id ?? 0,
        lessonId: lessonId,
        date: dateStr,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Delete time table entry failed', e);
      _setLoading(false);
      return false;
    }
    return false;
  }

  Future<bool> addMealMenu({
    required String title,
    required String menu,
    required String time,
  }) async {
    if (_user == null) return false;

    // Check permissions
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.addDailyMealMenu(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        title: title,
        menu: menu,
        time: time,
        date: dateStr,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Add meal menu failed', e);
      _setLoading(false);
      return false;
    }
    return false;
  }

  Future<bool> deleteMealMenuEntry({required String time}) async {
    if (_user == null) return false;

    // Check permissions
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.deleteMealMenu(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        time: time,
        date: dateStr,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Delete meal menu failed', e);
      _setLoading(false);
      return false;
    }
    return false;
  }

  Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      AppLogger.error('Pick PDF failed', e);
    }
    return null;
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

    if (!_isLoading) _setLoading(true);
    _errorMessage = null;

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

  Future<bool> pickAndUploadGalleryImage() async {
    if (_user == null || _selectedClass == null) return false;

    // Check permissions: Sadece superadmin ve teacher ekleyebilir.
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optimize image size
      );

      if (image == null) return false;

      final File file = File(image.path);
      final int sizeInBytes = await file.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 2) {
        _errorMessage = "Resim boyutu 2MB'dan büyük olamaz.";
        notifyListeners();
        return false;
      }

      _setLoading(true);
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final result = await _homeService.addDailyGallery(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        classId: _selectedClass!.id ?? 0,
        image: file,
        date: dateStr,
        userId: _user!.id ?? 0,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Upload gallery image failed', e);
      _setLoading(false);
      return false;
    }
    return false;
  }

  Future<bool> deleteGalleryImage(int imageId) async {
    if (_user == null) return false;

    // Check permissions: Sadece superadmin ve teacher silebilir.
    if (_user!.role != 'superadmin' && _user!.role != 'teacher') {
      _errorMessage = "Bu işlem için yetkiniz bulunmamaktadır.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final result = await _homeService.deleteGallery(
        schoolId: _user!.schoolId ?? 1,
        userKey: _user!.userKey ?? '',
        id: imageId,
      );

      if (result is Success<bool>) {
        await _fetchCalendarDetail();
        return true;
      } else if (result is Failure<bool>) {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Delete gallery image failed', e);
      _setLoading(false);
      return false;
    }
    return false;
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
