import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// User Provider
/// Manages user list and search
class UserProvider with ChangeNotifier {
  final _userService = UserService();

  List<User> _users = [];
  List<User> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<User> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getUsers();
      _error = null;
    } catch (e) {
      _error = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search users by username
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _userService.searchUsers(query);
      _error = null;
    } catch (e) {
      _error = 'Search failed: $e';
      _searchResults = [];
    }
    notifyListeners();
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      // Check cache first
      final cachedUser = _users.firstWhere(
        (user) => user.id == id,
        orElse: () => _users.first, // This will throw if list is empty
      );
      if (cachedUser.id == id) {
        return cachedUser;
      }
    } catch (_) {
      // User not in cache, fetch from API
    }

    try {
      return await _userService.getUserById(id);
    } catch (e) {
      _error = 'Failed to fetch user: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}

