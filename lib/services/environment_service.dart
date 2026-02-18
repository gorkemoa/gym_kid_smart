import 'package:shared_preferences/shared_preferences.dart';
import '../app/api_constants.dart';
import '../models/environment_model.dart';
import '../core/utils/logger.dart';

class EnvironmentService {
  static const String _keyEnvironment = 'selected_environment';

  static EnvironmentConfig? _currentConfig;

  static EnvironmentConfig? get currentConfig => _currentConfig;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final envString = prefs.getString(_keyEnvironment);

    if (envString != null) {
      try {
        final env = AppEnvironment.values.firstWhere(
          (e) => e.toString() == envString,
        );
        _currentConfig = EnvironmentConfig.availableEnvironments.firstWhere(
          (config) => config.environment == env,
        );
        ApiConstants.setEnvironment(
          url: _currentConfig!.baseUrl,
          authKey: _currentConfig!.authorizationKey,
        );
        AppLogger.info('Environment loaded: ${_currentConfig!.translationKey}');
      } catch (e) {
        AppLogger.error('Error loading environment: $e');
      }
    }
  }

  static Future<void> setEnvironment(EnvironmentConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEnvironment, config.environment.toString());
    _currentConfig = config;
    ApiConstants.setEnvironment(
      url: config.baseUrl,
      authKey: config.authorizationKey,
    );
    AppLogger.info('Environment set to: ${config.translationKey}');
  }

  static bool get isEnvironmentSelected => _currentConfig != null;
}
