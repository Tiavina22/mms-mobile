/// Group Model
class Group {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String createdBy;
  final DateTime createdAt;
  final int? memberCount;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    this.memberCount,
  });

  /// Create Group from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'private',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: json['member_count'] as int?,
    );
  }

  /// Convert Group to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      if (memberCount != null) 'member_count': memberCount,
    };
  }

  /// Create a copy with updated fields
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? createdBy,
    DateTime? createdAt,
    int? memberCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, type: $type)';
  }
}

