import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/user_model.dart';
import '../services/home_service.dart';
import '../core/utils/logger.dart';

class NewChatViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserModel> _participants = [];
  List<UserModel> get participants => _participants;

  int? _schoolId;
  String? _userKey;
  String? _userRole;

  Future<void> init(int schoolId, String userKey, String role) async {
    _schoolId = schoolId;
    _userKey = userKey;
    _userRole = role;
    await fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    if (_schoolId == null || _userKey == null || _userRole == null) return;

    _isLoading = true;
    _errorMessage = null;
    _participants = [];
    notifyListeners();

    try {
      if (_userRole == 'parent') {
        // Parent sees Teachers and Admins
        await _fetchTeachers();
        await _fetchAdmins();
      } else if (_userRole == 'teacher') {
        // Teacher sees Parents and Admins
        await _fetchParents();
        await _fetchAdmins();
      } else {
        // Admin sees Parents and Teachers
        await _fetchParents();
        await _fetchTeachers();
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Fetch participants failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchTeachers() async {
    final result = await _homeService.getAllTeachers(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );
    if (result is Success<List<UserModel>>) {
      _participants.addAll(result.data);
    }
  }

  Future<void> _fetchParents() async {
    final result = await _homeService.getAllParents(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );
    if (result is Success<List<UserModel>>) {
      _participants.addAll(result.data);
    }
  }

  Future<void> _fetchAdmins() async {
    final result = await _homeService.getAllAdmins(
      schoolId: _schoolId!,
      userKey: _userKey!,
    );
    if (result is Success<List<UserModel>>) {
      _participants.addAll(result.data);
    }
  }

  Future<bool> startChat(int recipientId) async {
    if (_schoolId == null || _userKey == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _homeService.addChatRoom(
        schoolId: _schoolId!,
        userKey: _userKey!,
        recipientUser: recipientId,
      );

      return result is Success<bool>;
    } catch (e) {
      AppLogger.error('Start chat failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
