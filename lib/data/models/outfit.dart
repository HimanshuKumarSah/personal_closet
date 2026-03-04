class Outfit {
  final String id;
  final String shirtId;
  final String pantId;
  final String shoesId;
  final String? jacketId;
  final String? capId;
  final String createdAt;

  Outfit({
    required this.id,
    required this.shirtId,
    required this.pantId,
    required this.shoesId,
    this.jacketId,
    this.capId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shirtId': shirtId,
      'pantId': pantId,
      'shoesId': shoesId,
      'jacketId': jacketId,
      'capId': capId,
      'createdAt': createdAt,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      shirtId: map['shirtId'],
      pantId: map['pantId'],
      shoesId: map['shoesId'],
      jacketId: map['jacketId'],
      capId: map['capId'],
      createdAt: map['createdAt'],
    );
  }
}