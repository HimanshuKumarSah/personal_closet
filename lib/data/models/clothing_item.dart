class ClothingItem {
  final String id;
  final String name;
  final String categoryId;
  final String color;
  final String imagePath;
  final String tags;
  final String createdAt;

  ClothingItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.color,
    required this.imagePath,
    required this.tags,
    required this.createdAt,
  });

  // Convert object → SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'color': color,
      'imagePath': imagePath,
      'tags': tags,
      'createdAt': createdAt,
    };
  }

  // Convert SQLite map → object
  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      color: map['color'],
      imagePath: map['imagePath'],
      tags: map['tags'] ?? '',
      createdAt: map['createdAt'],
    );
  }

  // Useful when editing clothing items later
  ClothingItem copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? color,
    String? imagePath,
    String? tags,
    String? createdAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}