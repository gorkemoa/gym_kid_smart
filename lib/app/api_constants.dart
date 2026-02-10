class ApiConstants {
  static const String baseUrl = 'https://smartkid.gymboreeizmir.com';

  // Auth
  static const String login = '/Api/Login';
  static const String allSettings = '/Api/AllSettings';
  static const String addToken = '/Api/addToken';
  static const String allNotices = '/Api/AllNotices';
  static const String allStudents = '/Api/AllStudents';

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Authorization': 'DcuV3wdDqrx-c#e#P-1dS#6n@dEFEd5hA354e',
  };
}
