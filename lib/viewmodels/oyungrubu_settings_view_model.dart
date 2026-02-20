import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/app_translations.dart';
import '../services/oyungrubu_auth_service.dart';
import 'base_view_model.dart';
import 'splash_view_model.dart';

class OyunGrubuSettingsViewModel extends BaseViewModel {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    // Initializer if needed later
    notifyListeners();
  }

  void refresh() {
    // Refresh logic if needed later
  }

  void onRetry() {
    // Retry logic if needed later
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> changeLanguage(
    String languageCode,
    SplashViewModel splashVM,
  ) async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    await AppTranslations.load(languageCode);
    await splashVM
        .init(); // to push changing locale to root and reload preferences
    _setLoading(false);
  }

  Future<void> logout() async {
    _setLoading(true);
    await OyunGrubuAuthService.logout();
    _setLoading(false);
  }
}
