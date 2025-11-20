/// Message Model (1-to-1 chat)
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isSent;
  final bool isRead;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final bool isEdited;
  final DateTime? editedAt;
  final String? previousContent;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isSent = true,
    this.isRead = false,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.isEdited = false,
    this.editedAt,
    this.previousContent,
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
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'] as String)
          : null,
      deletedBy: json['deleted_by'] as String?,
      isEdited: json['edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.tryParse(json['edited_at'] as String)
          : null,
      previousContent: json['previous_content'] as String?,
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
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
      'edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'previous_content': previousContent,
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
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    bool? isEdited,
    DateTime? editedAt,
    String? previousContent,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      previousContent: previousContent ?? this.previousContent,
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
