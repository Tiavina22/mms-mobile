/// Application Configuration
class AppConfig {
  // App Information
  static const String appName = 'MMS';
  static const String appVersion = '0.1.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String emailKey = 'email';
  static const String languageKey = 'language';
  static const String themeModeKey = 'theme_mode';

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'fr', 'es'];
  static const String defaultLanguage = 'en';

  // UI Configuration
  static const int maxMessageLength = 1000;
  static const int maxGroupNameLength = 50;
  static const int maxGroupDescriptionLength = 200;

  // Pagination
  static const int messagesPerPage = 50;
  static const int conversationsPerPage = 20;

  // WebSocket Configuration
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  static const int wsMaxReconnectAttempts = 5;
}
