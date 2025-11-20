/// Group Message Model
class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? senderUsername;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderUsername,
  });

  /// Create GroupMessage from JSON
  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: json['sender_username'] as String?,
    );
  }

  /// Convert GroupMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      if (senderUsername != null) 'sender_username': senderUsername,
    };
  }

  /// Create a copy with updated fields
  GroupMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    String? senderUsername,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderUsername: senderUsername ?? this.senderUsername,
    );
  }

  /// Check if current user is sender
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  @override
  String toString() {
    return 'GroupMessage(id: $id, groupId: $groupId, senderId: $senderId)';
  }
}

