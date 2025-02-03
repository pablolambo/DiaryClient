import 'dart:io';

class ApiUrls {
  static var baseUrl = 'http://10.0.2.2:5028'; // baseUrl
  static var baseLocalhostAndroidUrl = 'https://localhost:7144'; // baseLocalhostAndroidUrl

  // Badges
  static var getBadgesUrl = '$baseUrl/Badge/badges';

  // User
  static var getUserStatisticsUrl = '$baseUrl/User/statistics';
  static var getUserInfoUrl = '$baseUrl/User/me';
  static var createPushNotificationUrl = '$baseUrl/User/push-notifications';

  // Theme
  static String buyThemeUrl(String themeId) => '$baseUrl/Theme/unlock/$themeId';
  static var getThemesUrl = '$baseUrl/Theme/themes';
  static String setThemeByIdUrl(String themeId) => '$baseUrl/Theme/set/$themeId';

  // Entries
  static var createEntryUrl = '$baseUrl/Entries/create';
  static var searchEntriesUrl = '$baseUrl/Entries/search';
  static String getEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String editEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String deleteEntryByIdUrl(String entryId) => '$baseUrl/Entries/$entryId';
  static String setEntryAsFavouriteByIdUrl(String entryId) => '$baseUrl/Entries/favourite/$entryId';

  // Diary.Api
  static var registerUrl = '$baseUrl/register';
  static var loginUrl = '$baseUrl/login';
  static var refreshUrl = '$baseUrl/refresh';
  static var confirmEmailUrl = '$baseUrl/confirmEmail';
  static var resendConfirmationEmailUrl = '$baseUrl/resendConfirmationEmail';
  static var forgotPasswordUrl = '$baseUrl/forgotPassword';
  static var resetPasswordUrl = '$baseUrl/resetPassword';
  static var manage2faUrl = '$baseUrl/manage/2fa';
  static var getManageInfoUrl = '$baseUrl/manage/info';
  static var postManageInfoUrl = '$baseUrl/manage/info';

  static String getCurrentPlatform() {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5028';
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      baseUrl = 'https://localhost:7144';
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    } else {
      return 'Unknown';
    }
  }
}