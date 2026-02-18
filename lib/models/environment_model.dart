import '../app/api_constants.dart';

enum AppEnvironment { anaokulu, oyunGrubu }

class EnvironmentConfig {
  final AppEnvironment environment;
  final String translationKey;
  final String baseUrl;
  final String authorizationKey;
  final String iconAsset;

  EnvironmentConfig({
    required this.environment,
    required this.translationKey,
    required this.baseUrl,
    required this.authorizationKey,
    required this.iconAsset,
  });

  static List<EnvironmentConfig> availableEnvironments = [
    EnvironmentConfig(
      environment: AppEnvironment.anaokulu,
      translationKey: 'anaokulu',
      baseUrl: ApiConstants.anaokuluUrl,
      authorizationKey: ApiConstants.anaokuluKey,
      iconAsset: 'assets/app-logo.jpg',
    ),
    EnvironmentConfig(
      environment: AppEnvironment.oyunGrubu,
      translationKey: 'oyun_grubu',
      baseUrl: ApiConstants.oyunGrubuUrl,
      authorizationKey: ApiConstants.oyunGrubuKey,
      iconAsset: 'assets/app-logo.jpg',
    ),
  ];
}
