import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Local Storage Service
/// Manages secure token storage and app preferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(AppConfig.userIdKey, userId);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs?.getString(AppConfig.userIdKey);
  }

  /// Save username
  Future<void> saveUsername(String username) async {
    await _prefs?.setString(AppConfig.usernameKey, username);
  }

  /// Get username
  String? getUsername() {
    return _prefs?.getString(AppConfig.usernameKey);
  }

  /// Save email
  Future<void> saveEmail(String email) async {
    await _prefs?.setString(AppConfig.emailKey, email);
  }

  /// Get email
  String? getEmail() {
    return _prefs?.getString(AppConfig.emailKey);
  }

  /// Save language preference
  Future<void> saveLanguage(String language) async {
    await _prefs?.setString(AppConfig.languageKey, language);
  }

  /// Get language preference
  String getLanguage() {
    return _prefs?.getString(AppConfig.languageKey) ??
        AppConfig.defaultLanguage;
  }

  /// Save theme mode preference
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs?.setBool(AppConfig.themeModeKey, isDarkMode);
  }

  /// Get theme mode preference
  bool getThemeMode() {
    return _prefs?.getBool(AppConfig.themeModeKey) ?? false;
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}

