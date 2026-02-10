class ApiConstants {
  static const String baseUrl = 'https://smartkid.gymboreeizmir.com';

  // Auth
  static const String login = '/Api/Login';
  static const String allSettings = '/Api/AllSettings';

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
