import 'dart:convert';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication Service
/// Handles user signup, login, and authentication state
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiService();
  final _storage = StorageService();

  /// Sign up a new user
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    String? phone,
    String language = 'en',
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.signup,
        requiresAuth: false,
        body: {
          'username': username,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          'language': language,
        },
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        // Save authentication data
        await _saveUserData(token, user);

        return {'success': true, 'user': user, 'token': token};
      } else {
        return {'success': false, 'error': _api.getErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Login an existing user
  Future<Map<String, dynamic>> login({
    required String identifier, // email or username
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.login,
        requiresAuth: false,
        body: {'identifier': identifier, 'password': password},
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        // Save authentication data
        await _saveUserData(token, user);

        return {'success': true, 'user': user, 'token': token};
      } else {
        return {'success': false, 'error': _api.getErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<Map<String, dynamic>> checkUsernameAvailability(
    String username,
  ) async {
    try {
      final response = await _api.post(
        ApiConfig.checkUsername,
        requiresAuth: false,
        body: {'username': username},
      );

      if (_api.isSuccess(response)) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'available': data['available'] as bool? ?? false,
        };
      } else {
        return {'success': false, 'error': _api.getErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> checkEmailAvailability(String email) async {
    try {
      final response = await _api.post(
        ApiConfig.checkEmail,
        requiresAuth: false,
        body: {'email': email},
      );

      if (_api.isSuccess(response)) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'available': data['available'] as bool? ?? false,
        };
      } else {
        return {'success': false, 'error': _api.getErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> checkPhoneAvailability(String phone) async {
    try {
      final response = await _api.post(
        ApiConfig.checkPhone,
        requiresAuth: false,
        body: {'phone': phone},
      );

      if (_api.isSuccess(response)) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'available': data['available'] as bool? ?? false,
        };
      } else {
        return {'success': false, 'error': _api.getErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _storage.getUserId();
  }

  /// Get current username
  String? getCurrentUsername() {
    return _storage.getUsername();
  }

  /// Save user data to local storage
  Future<void> _saveUserData(String token, User user) async {
    await _storage.saveToken(token);
    await _storage.saveUserId(user.id);
    await _storage.saveUsername(user.username);
    await _storage.saveEmail(user.email);
    await _storage.saveLanguage(user.language);
  }
}
