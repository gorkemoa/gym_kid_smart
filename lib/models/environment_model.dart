enum AppEnvironment { anaokulu, oyunGrubu }

class EnvironmentConfig {
  final AppEnvironment environment;
  final String translationKey;
  final String baseUrl;
  final String iconAsset;

  EnvironmentConfig({
    required this.environment,
    required this.translationKey,
    required this.baseUrl,
    required this.iconAsset,
  });

  static List<EnvironmentConfig> availableEnvironments = [
    EnvironmentConfig(
      environment: AppEnvironment.anaokulu,
      translationKey: 'anaokulu',
      baseUrl: 'https://smartkid.gymboreeizmir.com',
      iconAsset: 'assets/app-logo.jpg',
    ),
    EnvironmentConfig(
      environment: AppEnvironment.oyunGrubu,
      translationKey: 'oyun_grubu',
      baseUrl: 'https://smartkid.oyungrubu.com',
      iconAsset: 'assets/app-logo.jpg',
    ),
  ];
}
