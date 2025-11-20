import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Authentication Provider
/// Manages authentication state
class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _storage = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize authentication state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // Load user data from storage
        final userId = _storage.getUserId();
        final username = _storage.getUsername();
        final email = _storage.getEmail();
        final language = _storage.getLanguage();

        if (userId != null && username != null && email != null) {
          _currentUser = User(
            id: userId,
            username: username,
            email: email,
            language: language,
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up a new user
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    String? phone,
    String language = 'en',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signup(
        username: username,
        email: email,
        password: password,
        phone: phone,
        language: language,
      );

      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] as String?;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Signup failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login a user
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        identifier: identifier,
        password: password,
      );

      if (result['success'] == true) {
        _currentUser = result['user'] as User;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] as String?;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

