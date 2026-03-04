class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final String tags;
  final String createdAt;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'tags': tags,
      'createdAt': createdAt,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      imagePath: map['imagePath'],
      tags: map['tags'],
      createdAt: map['createdAt'],
    );
  }
}