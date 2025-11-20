import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

/// API Service
/// Handles all HTTP requests to the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = StorageService();
  final _logger = Logger();

  /// GET request
  Future<http.Response> get(String endpoint,
      {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      _logger.d('GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(ApiConfig.timeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('GET Error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      _logger.d('POST $url');
      _logger.d('Body: $body');

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(ApiConfig.timeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('POST Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      _logger.d('PUT $url');
      _logger.d('Body: $body');

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(ApiConfig.timeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint,
      {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      _logger.d('DELETE $url');

      final response = await http
          .delete(url, headers: headers)
          .timeout(ApiConfig.timeout);

      _logResponse(response);
      return response;
    } catch (e) {
      _logger.e('DELETE Error: $e');
      rethrow;
    }
  }

  /// Get headers with optional authentication
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        return ApiConfig.authHeaders(token);
      }
    }
    return ApiConfig.defaultHeaders;
  }

  /// Log response details
  void _logResponse(http.Response response) {
    _logger.d('Response Status: ${response.statusCode}');
    if (response.body.isNotEmpty) {
      try {
        final jsonBody = jsonDecode(response.body);
        _logger.d('Response Body: $jsonBody');
      } catch (_) {
        _logger.d('Response Body: ${response.body}');
      }
    }
  }

  /// Check if response is successful
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Parse error message from response
  String getErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['error'] as String? ?? 'Unknown error';
    } catch (_) {
      return 'Request failed with status ${response.statusCode}';
    }
  }
}

