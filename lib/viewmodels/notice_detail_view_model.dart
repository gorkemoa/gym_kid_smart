import 'base_view_model.dart';
import '../models/notice_model.dart';

class NoticeDetailViewModel extends BaseViewModel {
  NoticeModel? _notice;
  NoticeModel? get notice => _notice;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void init(NoticeModel notice) {
    _notice = notice;
    notifyListeners();
  }

  Future<void> refresh() async {
    // Currently, notice is passed from the previous screen.
    // If we need to fetch fresh data for this specific notice, we can do it here.
    notifyListeners();
  }
}
