import 'dart:math';
import '../data/models/clothing_item.dart';
import '../data/models/category.dart';
import '../data/repositories/clothing_repository.dart';
import '../data/repositories/category_repository.dart';

class OutfitGeneratorService {
  final ClothingRepository _clothingRepo = ClothingRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

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

  Future<List<ClothingItem>?> generateOutfit() async {
    final clothingItems = await _clothingRepo.getAllClothing();
    final categories = await _categoryRepo.getAllCategories();

    if (clothingItems.isEmpty || categories.isEmpty) return null;

    /// Group clothing by categoryId
    final Map<String, List<ClothingItem>> grouped = {};

    for (var item in clothingItems) {
      grouped.putIfAbsent(item.categoryId, () => []);
      grouped[item.categoryId]!.add(item);
    }

    List<ClothingItem> outfit = [];

    ClothingItem? baseItem;

    /// Step 1 — Handle required categories
    final requiredCategories =
        categories.where((c) => c.required).toList();

    for (var category in requiredCategories) {
      final items = grouped[category.id];

      if (items == null || items.isEmpty) {
        return null; // cannot generate outfit
      }

      ClothingItem selected;

      if (baseItem == null) {
        selected = items[_random.nextInt(items.length)];
        baseItem = selected;
      } else {
        final compatible = items
            .where((i) =>
                isColorCompatible(baseItem!.color, i.color))
            .toList();

        if (compatible.isNotEmpty) {
          selected =
              compatible[_random.nextInt(compatible.length)];
        } else {
          selected = items[_random.nextInt(items.length)];
        }
      }

      outfit.add(selected);
    }

    /// Step 2 — Optional categories
    final optionalCategories = categories
        .where((c) => !c.required && c.enabled)
        .toList();

    for (var category in optionalCategories) {
      final items = grouped[category.id];

      if (items == null || items.isEmpty) continue;

      /// 50% chance to include optional category
      if (_random.nextBool()) {
        final compatible = items
            .where((i) =>
                baseItem == null ||
                isColorCompatible(baseItem!.color, i.color))
            .toList();

        ClothingItem selected;

        if (compatible.isNotEmpty) {
          selected =
              compatible[_random.nextInt(compatible.length)];
        } else {
          selected = items[_random.nextInt(items.length)];
        }

        outfit.add(selected);
      }
    }

    return outfit;
  }
}