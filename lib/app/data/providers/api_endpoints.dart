class ApiEndpoints {
  static const String baseUrl = 'https://urjaguru.in/api';
  static const String imgUrl = 'https://urjaguru.in/public';

  // Auth endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profile';

  // Vendor endpoints
  static const String vendorProfile = '$baseUrl/vendor/profile';
  static const String saveCompanies = '$baseUrl/vendor/companies';
  static const String saveCategories = '$baseUrl/vendor/categories';

  // Notifications
  static String getNotifications(int userId) => '$baseUrl/notifications/$userId';
  static const String markAsRead = '$baseUrl/notifications/{id}/read';
  static const String markAllAsRead = '$baseUrl/notifications/read-all';
  static const String deleteNotification = '$baseUrl/notifications/{id}';
  static const String clearAll = '$baseUrl/notifications/clear-all';

// Add more endpoints as needed
}