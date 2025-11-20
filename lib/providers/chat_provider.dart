import 'package:flutter/foundation.dart';
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
  String? _activeChatUserId;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get activeChatUserId => _activeChatUserId;

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

  void setActiveChat(String? userId) {
    _activeChatUserId = userId;
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
    try {
      final messages = await _messageService.getMessagesWith(userId);
      // Sort by created_at (oldest first) for display
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
        // Add to cache and maintain chronological order
        if (_messageCache.containsKey(receiverId)) {
          _messageCache[receiverId]!.add(message);
          // Sort by created_at to maintain order (oldest first)
          _messageCache[receiverId]!.sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
          );
        } else {
          _messageCache[receiverId] = [message];
        }

        // Also send via WebSocket for real-time delivery
        _wsService.sendMessage({
          'type': 'new_message',
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
      final currentUserId = _storage.getUserId();

      if (currentUserId == null) return;

      if (type == 'message') {
        final message = Message.fromJson(data);

        // Determine the other user ID
        final otherUserId = message.senderId == currentUserId
            ? message.receiverId
            : message.senderId;

        // Add to cache and maintain chronological order (oldest first)
        if (_messageCache.containsKey(otherUserId)) {
          final existing = _messageCache[otherUserId]!;
          // Check if message already exists
          final exists = existing.any((m) => m.id == message.id);
          if (!exists) {
            existing.add(message);
            // Sort by created_at to maintain order
            existing.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            _messageCache[otherUserId] = existing;
          }
        } else {
          _messageCache[otherUserId] = [message];
        }

        // Update conversations
        loadConversations();
        notifyListeners();
      } else if (type == 'message_read') {
        // Handle read receipt - update messages I sent that were read
        final senderId = data['sender_id'] as String?; // The one who read
        final receiverId = data['receiver_id'] as String?; // Me (the sender)

        if (receiverId == currentUserId && senderId != null) {
          // Update messages I sent to this user
          if (_messageCache.containsKey(senderId)) {
            final updated = _messageCache[senderId]!
                .map(
                  (message) =>
                      (message.senderId == currentUserId &&
                          message.receiverId == senderId &&
                          !message.isRead)
                      ? message.copyWith(isRead: true, readAt: DateTime.now())
                      : message,
                )
                .toList();
            _messageCache[senderId] = updated;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _error = 'Failed to handle incoming message: $e';
    }
  }

  Future<bool> editMessage(
    String otherUserId,
    String messageId,
    String content,
  ) async {
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
    _activeChatUserId = null;
    notifyListeners();
  }

  Future<void> markConversationAsRead(String otherUserId) async {
    try {
      await _messageService.markConversationAsRead(otherUserId);

      final currentUserId = _storage.getUserId();
      if (currentUserId != null && _messageCache.containsKey(otherUserId)) {
        final updated = _messageCache[otherUserId]!
            .map(
              (message) =>
                  (message.senderId == otherUserId &&
                      message.receiverId == currentUserId &&
                      !message.isRead)
                  ? message.copyWith(
                      isRead: true,
                      readAt: message.readAt ?? DateTime.now(),
                    )
                  : message,
            )
            .toList();
        _messageCache[otherUserId] = updated;
      }

      _conversations = _conversations
          .map(
            (conversation) => conversation.user.id == otherUserId
                ? conversation.copyWith(unreadCount: 0)
                : conversation,
          )
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark conversation as read: $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
