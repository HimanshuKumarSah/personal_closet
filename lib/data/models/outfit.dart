class Outfit {
  final String id;
  final String createdAt;

  Outfit({
    required this.id,
    required this.createdAt,
  });

  // Convert Outfit → SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
    };
  }

  // Convert SQLite Map → Outfit
  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      createdAt: map['createdAt'],
    );
  }

  // Optional helper for updates
  Outfit copyWith({
    String? id,
    String? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}