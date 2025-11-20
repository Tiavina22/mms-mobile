import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/message_service.dart';
import '../services/websocket_service.dart';
import '../services/storage_service.dart';

/// Chat Provider
/// Manages chat messages and conversations
class ChatProvider with ChangeNotifier {
  final _messageService = MessageService();
  final _wsService = WebSocketService();
  final _storage = StorageService();

  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messageCache = {};
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize chat provider
  Future<void> init() async {
    // Connect to WebSocket
    await _wsService.connect();

    // Listen to incoming messages
    _wsService.messages.listen((data) {
      _handleIncomingMessage(data);
    });

    // Load conversations
    await loadConversations();
  }

  /// Load conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 Loading conversations...');
      _conversations = await _messageService.getConversations();
      print('📱 Loaded ${_conversations.length} conversations');
      _error = null;
    } catch (e) {
      print('❌ Error loading conversations: $e');
      _error = 'Failed to load conversations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get messages with a user
  Future<List<Message>> getMessagesWithUser(String userId) async {
    // Check cache first
    if (_messageCache.containsKey(userId)) {
      return _messageCache[userId]!;
    }

    try {
      final messages = await _messageService.getMessagesWith(userId);
      _messageCache[userId] = messages;
      notifyListeners();
      return messages;
    } catch (e) {
      _error = 'Failed to load messages: $e';
      notifyListeners();
      return [];
    }
  }

  /// Send a message
  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final message = await _messageService.sendMessage(
        receiverId: receiverId,
        content: content,
      );

      if (message != null) {
        // Add to cache
        if (_messageCache.containsKey(receiverId)) {
          _messageCache[receiverId]!.add(message);
        } else {
          _messageCache[receiverId] = [message];
        }

        // Also send via WebSocket for real-time delivery
        _wsService.sendMessage({
          'type': 'message',
          'receiver_id': receiverId,
          'content': content,
        });

        // refresh conversations list so Chats tab shows latest contact
        await loadConversations();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  /// Handle incoming WebSocket message
  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;

      if (type == 'message') {
        final message = Message.fromJson(data);
        final currentUserId = _storage.getUserId();

        if (currentUserId != null) {
          // Determine the other user ID
          final otherUserId = message.senderId == currentUserId
              ? message.receiverId
              : message.senderId;

          // Add to cache
          if (_messageCache.containsKey(otherUserId)) {
            _messageCache[otherUserId]!.add(message);
          } else {
            _messageCache[otherUserId] = [message];
          }

          // Update conversations
          loadConversations();
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to handle incoming message: $e';
    }
  }

  Future<bool> editMessage(String otherUserId, String messageId, String content) async {
    try {
      final updated = await _messageService.editMessage(
        messageId: messageId,
        content: content,
      );

      if (updated != null) {
        if (_messageCache.containsKey(otherUserId)) {
          final list = _messageCache[otherUserId]!;
          final index = list.indexWhere((m) => m.id == messageId);
          if (index != -1) {
            list[index] = updated;
          }
        }
        await loadConversations();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to edit message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMessage(String otherUserId, String messageId) async {
    try {
      final deleted = await _messageService.deleteMessage(messageId);
      if (deleted != null) {
        if (_messageCache.containsKey(otherUserId)) {
          final list = _messageCache[otherUserId]!;
          final index = list.indexWhere((m) => m.id == messageId);
          if (index != -1) {
            list[index] = deleted;
          }
        }
        await loadConversations();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear messages cache for a user
  void clearMessagesCache(String userId) {
    _messageCache.remove(userId);
    notifyListeners();
  }

  /// Clear all cache
  void clearAllCache() {
    _messageCache.clear();
    _conversations.clear();
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}

