import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/class_model.dart';
import '../services/home_service.dart';

class DailyReportViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;

  int? _schoolId;
  String? _userKey;

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
      _classes = result.data;
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
