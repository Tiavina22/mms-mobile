import 'user.dart';

/// Conversation Model (represents a chat with another user)
class Conversation {
  final User user;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Create Conversation from JSON
  /// Can accept either a full conversation object or just a user object
  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Check if this is a User object or a Conversation object
    if (json.containsKey('user')) {
      // Full conversation object
      return Conversation(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        lastMessage: json['last_message'] as String?,
        lastMessageTime: json['last_message_time'] != null
            ? DateTime.parse(json['last_message_time'] as String)
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
      );
    } else {
      // Just a user object from backend's conversations endpoint
      return Conversation(
        user: User.fromJson(json),
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
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
    };
  }

  @override
  String toString() {
    return 'Conversation(userId: ${user.id}, username: ${user.username})';
  }
}

