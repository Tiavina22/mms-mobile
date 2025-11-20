/// User Model
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final String language;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatar,
    required this.language,
    required this.createdAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      language: json['language'] as String? ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? language,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email)';
  }
}
