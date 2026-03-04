import 'dart:math';
import '../data/models/clothing_item.dart';
import '../data/repositories/clothing_repository.dart';

class OutfitGeneratorService {
  final ClothingRepository _repo = ClothingRepository();
  final Random _random = Random();

  /// Neutral colors match almost everything
  final List<String> neutralColors = [
    'black',
    'white',
    'grey',
    'gray',
    'beige',
    'brown',
    'navy'
  ];

  /// Color harmony rules
  final Map<String, List<String>> colorHarmony = {
    'black': ['white', 'grey', 'beige', 'blue', 'navy'],
    'white': ['black', 'blue', 'grey', 'beige'],
    'blue': ['white', 'grey', 'beige', 'black'],
    'navy': ['white', 'beige', 'grey'],
    'beige': ['white', 'brown', 'navy', 'black'],
    'brown': ['beige', 'white', 'blue'],
    'grey': ['white', 'black', 'blue'],
  };

  String normalize(String color) {
    return color.trim().toLowerCase();
  }

  bool isColorCompatible(String base, String target) {
    base = normalize(base);
    target = normalize(target);

    if (neutralColors.contains(base)) return true;

    if (colorHarmony.containsKey(base)) {
      return colorHarmony[base]!.contains(target);
    }

    return false;
  }

  Future<Map<String, ClothingItem?>?> generateOutfit() async {
    final items = await _repo.getAllClothing();

    final shirts =
        items.where((i) => i.category == 'shirts').toList();
    final pants =
        items.where((i) => i.category == 'pants').toList();
    final shoes =
        items.where((i) => i.category == 'shoes').toList();
    final jackets =
        items.where((i) => i.category == 'jackets').toList();
    final caps =
        items.where((i) => i.category == 'caps').toList();

    /// Must have shirt + pants + shoes
    if (shirts.isEmpty || pants.isEmpty || shoes.isEmpty) {
      return null;
    }

    /// Step 1 — Pick base shirt
    final shirt = shirts[_random.nextInt(shirts.length)];

    /// Step 2 — Find matching pants
    final compatiblePants = pants
        .where((p) =>
            isColorCompatible(shirt.color, p.color))
        .toList();

    final pant = compatiblePants.isNotEmpty
        ? compatiblePants[
            _random.nextInt(compatiblePants.length)]
        : pants[_random.nextInt(pants.length)];

    /// Step 3 — Prefer neutral shoes
    final neutralShoes = shoes
        .where((s) =>
            neutralColors.contains(normalize(s.color)))
        .toList();

    final shoe = neutralShoes.isNotEmpty
        ? neutralShoes[_random.nextInt(neutralShoes.length)]
        : shoes[_random.nextInt(shoes.length)];

    /// Step 4 — Optional jacket
    ClothingItem? jacket;

    if (jackets.isNotEmpty) {
      final compatibleJackets = jackets
          .where((j) =>
              isColorCompatible(shirt.color, j.color) ||
              isColorCompatible(pant.color, j.color))
          .toList();

      if (compatibleJackets.isNotEmpty) {
        jacket = compatibleJackets[
            _random.nextInt(compatibleJackets.length)];
      }
    }

    /// Step 5 — Optional cap
    ClothingItem? cap;

    if (caps.isNotEmpty) {
      final compatibleCaps = caps
          .where((c) =>
              normalize(c.color) ==
                  normalize(shoe.color) ||
              normalize(c.color) ==
                  normalize(shirt.color))
          .toList();

      if (compatibleCaps.isNotEmpty) {
        cap = compatibleCaps[
            _random.nextInt(compatibleCaps.length)];
      }
    }

    return {
      'shirt': shirt,
      'pant': pant,
      'shoe': shoe,
      'jacket': jacket,
      'cap': cap,
    };
  }
}