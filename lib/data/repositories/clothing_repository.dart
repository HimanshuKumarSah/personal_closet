import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/clothing_item.dart';

class ClothingRepository {

  // ======================================
  // INSERT CLOTHING ITEM
  // ======================================
  Future<void> insertClothing(ClothingItem item) async {
    final Database db = await DBHelper.database;

    await db.insert(
      'clothing',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ======================================
  // GET ALL CLOTHING
  // ======================================
  Future<List<ClothingItem>> getAllClothing() async {
    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps =
        await db.query('clothing', orderBy: 'createdAt DESC');

    return maps.map((map) => ClothingItem.fromMap(map)).toList();
  }

  // ======================================
  // GET CLOTHING BY CATEGORY
  // ======================================
  Future<List<ClothingItem>> getClothingByCategory(String categoryId) async {
    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'clothing',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => ClothingItem.fromMap(map)).toList();
  }

  // ======================================
  // GET CLOTHING BY ID
  // ======================================
  Future<ClothingItem?> getClothingById(String id) async {
    final Database db = await DBHelper.database;

    final result = await db.query(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return ClothingItem.fromMap(result.first);
    }

    return null;
  }

  // ======================================
  // DELETE CLOTHING ITEM
  // ======================================
  Future<void> deleteClothing(String id) async {
    final db = await DBHelper.database;

    await db.delete(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}