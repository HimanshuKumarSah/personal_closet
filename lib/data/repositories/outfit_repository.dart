import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/outfit.dart';
import '../models/outfit_item.dart';
import 'package:uuid/uuid.dart';

class OutfitRepository {

  final uuid = const Uuid();

  // ======================================
  // INSERT OUTFIT WITH ITEMS
  // ======================================
  Future<void> insertOutfit(Outfit outfit, List<OutfitItem> items) async {

    final Database db = await DBHelper.database;

    await db.transaction((txn) async {

      // Insert outfit container
      await txn.insert(
        'outfits',
        outfit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert outfit items
      for (var item in items) {
        await txn.insert(
          'outfit_items',
          item.toMap(),
        );
      }

    });
  }

  // ======================================
  // GET ALL OUTFITS
  // ======================================
  Future<List<Outfit>> getAllOutfits() async {

    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps =
        await db.query('outfits', orderBy: 'createdAt DESC');

    return maps.map((map) => Outfit.fromMap(map)).toList();
  }

  // ======================================
  // GET ITEMS FOR AN OUTFIT
  // ======================================
  Future<List<OutfitItem>> getOutfitItems(String outfitId) async {

    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'outfit_items',
      where: 'outfitId = ?',
      whereArgs: [outfitId],
    );

    return maps.map((map) => OutfitItem.fromMap(map)).toList();
  }

  // ======================================
  // DELETE OUTFIT (AND ITS ITEMS)
  // ======================================
  Future<void> deleteOutfit(String id) async {

    final Database db = await DBHelper.database;

    await db.transaction((txn) async {

      // Delete outfit items
      await txn.delete(
        'outfit_items',
        where: 'outfitId = ?',
        whereArgs: [id],
      );

      // Delete outfit container
      await txn.delete(
        'outfits',
        where: 'id = ?',
        whereArgs: [id],
      );

    });
  }
}