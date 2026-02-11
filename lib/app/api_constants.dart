class ApiConstants {
  static const String baseUrl = 'https://smartkid.gymboreeizmir.com';

  // Auth
  static const String login = '/Api/Login';
  static const String allSettings = '/Api/AllSettings';
  static const String addToken = '/Api/addToken';
  static const String allNotices = '/Api/AllNotices';
  static const String allStudents = '/Api/AllStudents';
  static const String allClasses = '/Api/AllClasses';
  static const String dailyStudent = '/Api/DailyStudent';
  static const String dailyStudentsNote = '/Api/DailyStudentsNote';
  static const String dailyReceiving = '/Api/DailyReceiving';
  static const String dailyActivity = '/Api/DailyActivity';
  static const String dailySocial = '/Api/DailySocial';
  static const String allActivitiesValue = '/Api/AllActivitiesValue';
  static const String activitiesValue = '/Api/ActivitiesValue';
  static const String activitiesTitle = '/Api/ActivitiesTitle';
  static const String allActivitiesTitle = '/Api/AllActivitiesTitle';
  static const String socialsTitle = '/Api/SocialsTitle';
  static const String allSocialsTitle = '/Api/AllSocialsTitle';
  static const String dailyMeal = '/Api/DailyMeal';
  static const String allMealsTitle = '/Api/AllMealsTitle';
  static const String allMealsValue = '/Api/AllMealsValue';

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Authorization': 'DcuV3wdDqrx-c#e#P-1dS#6n@dEFEd5hA354e',
  };
}
