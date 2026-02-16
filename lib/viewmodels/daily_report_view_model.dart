import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/class_model.dart';
import '../services/home_service.dart';

class DailyReportViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<ClassModel> get filteredClasses {
    if (_searchQuery.isEmpty) return _classes;
    return _classes
        .where(
          (c) =>
              (c.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  int? _schoolId;
  int? get schoolId => _schoolId;
  String? _userKey;
  String? get userKey => _userKey;

  void init(int schoolId, String userKey) {
    _schoolId = schoolId;
    _userKey = userKey;
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (_schoolId == null || _userKey == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.getAllClasses(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );

    if (result is Success<List<ClassModel>>) {
      _classes = result.data
        ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    } else if (result is Failure<List<ClassModel>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    _fetchClasses();
  }
}
