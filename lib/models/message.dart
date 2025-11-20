/// Message Model (1-to-1 chat)
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isSent;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isSent = true,
    this.isRead = false,
  });

  /// Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isSent: json['is_sent'] as bool? ?? true,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  /// Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_sent': isSent,
      'is_read': isRead,
    };
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isSent,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Check if current user is sender
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, receiverId: $receiverId)';
  }
}
