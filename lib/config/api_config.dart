/// API Configuration
/// Contains all API endpoints and base URL
class ApiConfig {
  // Base URL - Change this to your backend URL
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For Physical Device: use your computer's IP address
  static const String baseUrl = 'http://192.168.1.206:8080';

  // WebSocket URL
  static const String wsUrl = 'ws://192.168.1.206:8080/api/v1/ws';

  // API Endpoints
  static const String apiPrefix = '/api/v1';

  // Auth endpoints
  static const String signup = '$apiPrefix/auth/signup';
  static const String login = '$apiPrefix/auth/login';
  static const String checkUsername = '$apiPrefix/auth/check-username';
  static const String checkEmail = '$apiPrefix/auth/check-email';
  static const String checkPhone = '$apiPrefix/auth/check-phone';

  // User endpoints
  static const String users = '$apiPrefix/users';
  static String userById(String id) => '$apiPrefix/users/$id';

  // Message endpoints
  static const String messages = '$apiPrefix/messages';
  static const String sendMessage = '$apiPrefix/messages';
  static String messagesBetween(String userId) =>
      '$apiPrefix/messages/conversation/$userId';
  static const String conversations = '$apiPrefix/messages/conversations';
  static String markConversationRead(String userId) =>
      '$apiPrefix/messages/read/$userId';
  static const String unreadMessageCount = '$apiPrefix/messages/unread/count';
  static String messageById(String messageId) =>
      '$apiPrefix/messages/$messageId';

  // Group endpoints
  static const String groups = '$apiPrefix/groups';
  static const String myGroups = '$apiPrefix/groups/my';
  static String groupById(String id) => '$apiPrefix/groups/$id';
  static String groupMembers(String id) => '$apiPrefix/groups/$id/members';
  static String addGroupMember(String id) => '$apiPrefix/groups/$id/members';
  static String removeGroupMember(String groupId, String userId) =>
      '$apiPrefix/groups/$groupId/members/$userId';
  static String groupMessages(String id) => '$apiPrefix/groups/$id/messages';
  static const String sendGroupMessage = '$apiPrefix/groups/messages';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
