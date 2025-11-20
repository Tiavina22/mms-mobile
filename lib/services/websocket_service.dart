import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

/// WebSocket Service
/// Manages real-time WebSocket connection for chat
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final _storage = StorageService();
  final _logger = Logger();

  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isConnecting || isConnected) {
      _logger.w('WebSocket already connected or connecting');
      return;
    }

    _isConnecting = true;

    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final wsUrl = Uri.parse('${ApiConfig.wsUrl}?token=$token');
      _logger.i('Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
          _reconnectAttempts = 0; // Reset on successful message
        },
        onError: (error) {
          _logger.e('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          _logger.w('WebSocket connection closed');
          _handleDisconnect();
        },
      );

      _isConnecting = false;
      _logger.i('WebSocket connected successfully');
    } catch (e) {
      _logger.e('Failed to connect to WebSocket: $e');
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  /// Send message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (!isConnected) {
      _logger.w('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      _logger.d('Message sent: $jsonMessage');
    } catch (e) {
      _logger.e('Failed to send message: $e');
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts = 0;
    _isConnecting = false;
    _logger.i('WebSocket disconnected');
  }

  /// Handle incoming message
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      _logger.d('Message received: $message');
      _messageController.add(message);
    } catch (e) {
      _logger.e('Failed to parse message: $e');
    }
  }

  /// Handle disconnection and attempt reconnect
  void _handleDisconnect() {
    _channel = null;
    _isConnecting = false;

    if (_reconnectAttempts < AppConfig.wsMaxReconnectAttempts) {
      _reconnectAttempts++;
      _logger.i(
          'Attempting to reconnect (attempt $_reconnectAttempts/${AppConfig.wsMaxReconnectAttempts})');

      _reconnectTimer = Timer(AppConfig.wsReconnectDelay, () {
        connect();
      });
    } else {
      _logger.e('Max reconnection attempts reached');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

