class ApiUrls {
  static const baseUrl = 'https://localhost:7144';

  // Badges
  static const getBadgesUrl = '$baseUrl/Badge/badges';

  // User
  static const getUserStatisticsUrl = '$baseUrl/User/statistics';
  static const getUserInfoUrl = '$baseUrl/User/me';
  static const createPushNotificationUrl = '$baseUrl/User/push-notifications';

  // Theme
  static String buyThemeUrl(String themeId) => '$baseUrl/Theme/unlock/$themeId';
  static const getThemesUrl = '$baseUrl/Theme/themes';
  static String setThemeByIdUrl(String themeId) => '$baseUrl/Theme/set/$themeId';

  // Entries
  static const createEntryUrl = '$baseUrl/Entries/create';
  static const searchEntriesUrl = '$baseUrl/Entries/search';
  static String getEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String editEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String deleteEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String setEntryAsFavouriteByIdUrl(String entryId) => '$baseUrl/Entries/favourite/$entryId';

  // Diary.Api
  static const registerUrl = '$baseUrl/register';
  static const loginUrl = '$baseUrl/login';
  static const refreshUrl = '$baseUrl/refresh';
  static const confirmEmailUrl = '$baseUrl/confirmEmail';
  static const resendConfirmationEmailUrl = '$baseUrl/resendConfirmationEmail';
  static const forgotPasswordUrl = '$baseUrl/forgotPassword';
  static const resetPasswordUrl = '$baseUrl/resetPassword';
  static const manage2faUrl = '$baseUrl/manage/2fa';
  static const getManageInfoUrl = '$baseUrl/manage/info';
  static const postManageInfoUrl = '$baseUrl/manage/info';
}