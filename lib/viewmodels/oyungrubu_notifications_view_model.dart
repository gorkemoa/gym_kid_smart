import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../models/oyungrubu_notification_model.dart';
import '../models/oyungrubu_notifications_response.dart';
import '../services/oyungrubu_notification_service.dart';

class OyunGrubuNotificationsViewModel extends BaseViewModel {
  final OyunGrubuNotificationService _notificationService =
      OyunGrubuNotificationService();

  List<OyunGrubuNotificationModel>? _notifications;
  List<OyunGrubuNotificationModel>? get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _notificationService.getNotifications();

    _isLoading = false;
    if (result is Success<OyunGrubuNotificationsResponse>) {
      _notifications = result.data.data;
    } else if (result is Failure<OyunGrubuNotificationsResponse>) {
      _errorMessage = result.message;
      _notifications = [];
    }
    notifyListeners();
  }
}
