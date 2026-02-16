import 'base_view_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/meal_menu_model.dart';
import '../services/home_service.dart';
import '../core/network/api_result.dart';

class FoodListViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MealMenuModel> _mealMenus = [];
  List<MealMenuModel> get mealMenus => _mealMenus;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int? _schoolId;
  String? _userKey;

  Future<void> init(int schoolId, String userKey) async {
    await initializeDateFormatting();
    _schoolId = schoolId;
    _userKey = userKey;
    _fetchMealMenus();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDate = selectedDay;
    notifyListeners();
  }

  List<MealMenuModel> getMealsForSelectedDate() {
    final dateStr = _selectedDate.toString().split(' ')[0];
    return _mealMenus.where((menu) => menu.date == dateStr).toList();
  }

  Future<void> _fetchMealMenus() async {
    if (_schoolId == null || _userKey == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.getMealMenus(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );

    if (result is Success<List<MealMenuModel>>) {
      _mealMenus = result.data;
    } else if (result is Failure<List<MealMenuModel>>) {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResult<bool>> deleteMealMenu({
    required String time,
    required String date,
    required String role,
  }) async {
    if (_schoolId == null || _userKey == null) {
      return Failure('Missing parameters');
    }

    if (role != 'superadmin' && role != 'teacher') {
      return Failure('Yetkisiz işlem');
    }

    final result = await _homeService.deleteMealMenu(
      schoolId: _schoolId!,
      userKey: _userKey!,
      time: time,
      date: date,
    );

    if (result is Success<bool>) {
      await _fetchMealMenus();
      notifyListeners();
    }

    return result;
  }

  void refresh() {
    _fetchMealMenus();
  }
}
