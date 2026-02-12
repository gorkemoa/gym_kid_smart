import 'package:flutter/material.dart';
import '../core/network/api_result.dart';
import '../models/chat_room_model.dart';
import '../services/home_service.dart';
import '../core/utils/logger.dart';

class ChatViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ChatRoomModel> _chatRooms = [];
  List<ChatRoomModel> get chatRooms => _chatRooms;

  int? _schoolId;
  String? _userKey;
  int? _id;

  Future<void> init(int schoolId, String userKey, int id) async {
    _schoolId = schoolId;
    _userKey = userKey;
    _id = id;
    await refresh();
  }

  Future<void> refresh() async {
    if (_schoolId == null || _userKey == null || _id == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _homeService.getChatRooms(
        schoolId: _schoolId!,
        userKey: _userKey!,
        id: _id!,
      );

      if (result is Success<List<ChatRoomModel>>) {
        _chatRooms = result.data;
      } else if (result is Failure<List<ChatRoomModel>>) {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Chat Rooms fetch failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onRetry() {
    refresh();
  }
}
