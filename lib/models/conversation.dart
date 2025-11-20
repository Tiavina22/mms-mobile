import 'user.dart';

/// Conversation Model (represents a chat with another user)
class Conversation {
  final User user;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? lastMessageSenderId;
  final bool lastMessageIsRead;

  Conversation({
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.lastMessageSenderId,
    this.lastMessageIsRead = false,
  });

  /// Create Conversation from JSON
  /// Can accept either a full conversation object or just a user object
  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Check if this is a User object or a Conversation object
    if (json.containsKey('user')) {
      // Full conversation object
      return Conversation(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        lastMessage: _normalizeLastMessage(json['last_message']),
        lastMessageTime: json['last_message_time'] != null
            ? DateTime.parse(json['last_message_time'] as String)
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
        lastMessageSenderId: json['last_message_sender_id'] as String?,
        lastMessageIsRead: json['last_message_is_read'] as bool? ?? false,
      );
    } else {
      // Just a user object from backend's conversations endpoint
      return Conversation(
        user: User.fromJson(json),
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
        lastMessageSenderId: null,
        lastMessageIsRead: false,
      );
    }
  }

  /// Convert Conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'last_message_sender_id': lastMessageSenderId,
      'last_message_is_read': lastMessageIsRead,
    };
  }

  Conversation copyWith({
    User? user,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? lastMessageSenderId,
    bool? lastMessageIsRead,
  }) {
    return Conversation(
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageIsRead: lastMessageIsRead ?? this.lastMessageIsRead,
    );
  }

  @override
  String toString() {
    return 'Conversation(userId: ${user.id}, username: ${user.username})';
  }
}

String? _normalizeLastMessage(dynamic value) {
  if (value == null) return null;
  final message = value as String;
  if (message.trim().isEmpty) return null;
  return message;
}
