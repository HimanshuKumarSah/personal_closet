class Category {
  final String id;
  final String name;
  final bool required;
  final bool enabled;
  final String createdAt;

  Category({
    required this.id,
    required this.name,
    required this.required,
    required this.enabled,
    required this.createdAt,
  });

  // Convert Category → Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'required': required ? 1 : 0,
      'enabled': enabled ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  // Convert SQLite Map → Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      required: map['required'] == 1,
      enabled: map['enabled'] == 1,
      createdAt: map['createdAt'],
    );
  }

  // Useful for updating toggles
  Category copyWith({
    String? id,
    String? name,
    bool? required,
    bool? enabled,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      required: required ?? this.required,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}