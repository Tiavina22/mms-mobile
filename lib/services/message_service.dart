import 'dart:convert';
import '../config/api_config.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import 'api_service.dart';

/// Message Service
/// Handles message operations
class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final _api = ApiService();

  /// Send a message to a user
  Future<Message?> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.sendMessage,
        body: {
          'receiver_id': receiverId,
          'content': content,
        },
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return Message.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages between current user and another user
  Future<List<Message>> getMessagesWith(String userId) async {
    try {
      final response = await _api.get(ApiConfig.messagesBetween(userId));

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Get recent conversations
  Future<List<Conversation>> getConversations() async {
    try {
      print('🔍 Fetching conversations from API...');
      final response = await _api.get(ApiConfig.conversations);
      print('🔍 Response status: ${response.statusCode}');

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        print('🔍 Response data: $responseData');
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        print('🔍 Number of conversations: ${data.length}');
        final conversations = data.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList();
        print('🔍 Parsed conversations: ${conversations.length}');
        return conversations;
      } else {
        print('❌ API error: ${_api.getErrorMessage(response)}');
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      print('❌ Exception in getConversations: $e');
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  Future<Message?> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await _api.put(
        ApiConfig.messageById(messageId),
        body: {'content': content},
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return Message.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<Message?> deleteMessage(String messageId) async {
    try {
      final response = await _api.delete(
        ApiConfig.messageById(messageId),
      );

      if (_api.isSuccess(response)) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>;
        return Message.fromJson(data);
      } else {
        throw Exception(_api.getErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}

