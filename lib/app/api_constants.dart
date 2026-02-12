class ApiConstants {
  static const String baseUrl = 'https://smartkid.gymboreeizmir.com';

  // Auth
  static const String login = '/Api/Login';
  static const String allSettings = '/Api/AllSettings';
  static const String addToken = '/Api/addToken';
  static const String allNotices = '/Api/AllNotices';
  static const String notices = '/Api/Notices';
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
  static const String studentMedicament = '/Api/StudentMedicament';
  static const String addStudentMedicament = '/Api/AddStudentMedicament';
  static const String dailyMedicament = '/Api/DailyMedicament';
  static const String dailyMealMenus = '/Api/DailyMealMenus';
  static const String allMealMenus = '/Api/allMealMenus';
  static const String deleteMealMenu = '/Api/deleteMealMenu';
  static const String dailyGallery = '/Api/DailyGallery';
  static const String deleteGallery = '/Api/deleteGallery';
  static const String dailyTimeTable = '/Api/DailyTimeTable';
  static const String deleteTimeTable = '/Api/deleteTimeTable';
  static const String allLessons = '/Api/AllLessons';
  static const String calendarDetail = '/Api/CalendarDetail';
  static const String deleteDailySocial = '/Api/deleteDailySocial';
  static const String deleteDailyActivity = '/Api/deleteDailyActivity';
  static const String deleteDailyMeal = '/Api/deleteDailyMeal';
  static const String getChatRoom = '/Api/getChatRoom';
  static const String getChatDetail = '/Api/getChatDetail';
  static const String addChatDetail = '/Api/addChatDetail';
  static const String addChatRoom = '/Api/addChatRoom';
  static const String allTeachers = '/Api/AllTeachers';
  static const String allParents = '/Api/AllParents';
  static const String allAdmin = '/Api/AllAdmin';
  static const String updateStatusChat = '/Api/updateStatusChat';

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Authorization': 'DcuV3wdDqrx-c#e#P-1dS#6n@dEFEd5hA354e',
  };
}
