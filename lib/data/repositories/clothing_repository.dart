import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/clothing_item.dart';

class ClothingRepository {
  Future<void> insertClothing(ClothingItem item) async {
    final Database db = await DBHelper.database;

    await db.insert(
      'clothing',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClothingItem>> getAllClothing() async {
    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps =
        await db.query('clothing', orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
  Future<void> deleteClothing(String id) async {
    final db = await DBHelper.database;
    await db.delete(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<ClothingItem?> getClothingById(String id) async {
    final db = await DBHelper.database;

    final result = await db.query(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return ClothingItem.fromMap(result.first);
    }

    return null;
  }
  Future<void> deleteOutfit(String id) async {
    final db = await DBHelper.database;

    await db.delete(
      'outfits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}