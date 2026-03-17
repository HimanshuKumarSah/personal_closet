class OutfitItem {
  final String id;
  final String outfitId;
  final String clothingId;
  final String categoryId;

  OutfitItem({
    required this.id,
    required this.outfitId,
    required this.clothingId,
    required this.categoryId,
  });

  // Convert object → SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'outfitId': outfitId,
      'clothingId': clothingId,
      'categoryId': categoryId,
    };
  }

  // Convert SQLite map → object
  factory OutfitItem.fromMap(Map<String, dynamic> map) {
    return OutfitItem(
      id: map['id'],
      outfitId: map['outfitId'],
      clothingId: map['clothingId'],
      categoryId: map['categoryId'],
    );
  }

  // Useful when modifying outfit items later
  OutfitItem copyWith({
    String? id,
    String? outfitId,
    String? clothingId,
    String? categoryId,
  }) {
    return OutfitItem(
      id: id ?? this.id,
      outfitId: outfitId ?? this.outfitId,
      clothingId: clothingId ?? this.clothingId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}