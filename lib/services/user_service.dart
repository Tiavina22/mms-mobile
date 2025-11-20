import 'dart:convert';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

/// User Service
/// Handles user-related operations
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final _api = ApiService();

  /// Get all users
  Future<List<User>> getUsers() async {
    try {
      final response = await _api.get(ApiConfig.users);

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _api.get(ApiConfig.userById(id));

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Search users by username
  Future<List<User>> searchUsers(String query) async {
    try {
      final users = await getUsers();
      return users
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

