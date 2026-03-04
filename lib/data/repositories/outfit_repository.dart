import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/outfit.dart';

class OutfitRepository {
  Future<void> insertOutfit(Outfit outfit) async {
    final Database db = await DBHelper.database;

    await db.insert(
      'outfits',
      outfit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Outfit>> getAllOutfits() async {
    final Database db = await DBHelper.database;

    final List<Map<String, dynamic>> maps =
        await db.query('outfits', orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return Outfit.fromMap(maps[i]);
    });
  }

  Future<void> deleteOutfit(String id) async {
    final Database db = await DBHelper.database;

    await db.delete(
      'outfits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}