import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/chat_message_model.dart';
import '../services/home_service.dart';
import '../core/utils/logger.dart';

class ChatDetailViewModel extends BaseViewModel {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  final TextEditingController messageController = TextEditingController();

  int? _schoolId;
  String? _userKey;
  int? _chatRoomId;

  Future<void> init(int schoolId, String userKey, int chatRoomId) async {
    _schoolId = schoolId;
    _userKey = userKey;
    _chatRoomId = chatRoomId;
    await fetchMessages();
  }

  Future<void> fetchMessages() async {
    if (_schoolId == null || _userKey == null || _chatRoomId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _homeService.getChatDetail(
        schoolId: _schoolId!,
        userKey: _userKey!,
        id: _chatRoomId!,
      );

      if (result is Success<List<ChatMessageModel>>) {
        _messages = result.data;
      } else if (result is Failure<List<ChatMessageModel>>) {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('Chat messages fetch failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty ||
        _schoolId == null ||
        _userKey == null ||
        _chatRoomId == null) {
      return false;
    }

    try {
      final result = await _homeService.addChatDetail(
        schoolId: _schoolId!,
        userKey: _userKey!,
        id: _chatRoomId!,
        description: text,
      );

      if (result is Success<bool>) {
        messageController.clear();
        await fetchMessages();
        return true;
      } else {
        AppLogger.warning(
          'Send message failed: ${(result as Failure).message}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Send message failed', e);
      return false;
    }
  }

  Future<bool> updateStatus(int status) async {
    if (_schoolId == null || _userKey == null || _chatRoomId == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _homeService.updateStatusChat(
        schoolId: _schoolId!,
        userKey: _userKey!,
        id: _chatRoomId!,
        status: status,
      );

      if (result is Success<bool>) {
        return true;
      } else {
        AppLogger.warning(
          'Update status failed: ${(result as Failure).message}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Update status failed', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
