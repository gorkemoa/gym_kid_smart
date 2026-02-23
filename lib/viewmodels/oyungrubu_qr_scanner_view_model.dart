import 'base_view_model.dart';
import '../core/network/api_result.dart';
import '../services/oyungrubu_class_service.dart';
import '../core/utils/logger.dart';

class OyunGrubuQRScannerViewModel extends BaseViewModel {
  final OyunGrubuClassService _classService = OyunGrubuClassService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> scanQR({required int studentId, required String qrToken}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final result = await _classService.scanLessonQR(
        studentId: studentId,
        qrToken: qrToken,
      );

      if (result is Success<String>) {
        _isSuccess = true;
        _successMessage = result.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (result is Failure<String>) {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.error('QR Scan error', e);
      _errorMessage = 'error_occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
