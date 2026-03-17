import 'package:sqflite/sqflite.dart';
import '../../data/database/db_helper.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {

  final uuid = const Uuid();

  // ======================================
  // GET ALL CATEGORIES
  // ======================================

  Future<List<Category>> getAllCategories() async {
    final db = await DBHelper.database;

    final result = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return result.map((map) => Category.fromMap(map)).toList();
  }

  // ======================================
  // GET CATEGORY BY ID
  // ======================================

  Future<Category?> getCategoryById(String id) async {
    final db = await DBHelper.database;

    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Category.fromMap(result.first);
  }

  // ======================================
  // GET REQUIRED CATEGORIES
  // ======================================

  Future<List<Category>> getRequiredCategories() async {
    final db = await DBHelper.database;

    final result = await db.query(
      'categories',
      where: 'required = ?',
      whereArgs: [1],
    );

    return result.map((map) => Category.fromMap(map)).toList();
  }

  // ======================================
  // GET ENABLED CATEGORIES
  // ======================================

  Future<List<Category>> getEnabledCategories() async {
    final db = await DBHelper.database;

    final result = await db.query(
      'categories',
      where: 'enabled = ?',
      whereArgs: [1],
    );

    return result.map((map) => Category.fromMap(map)).toList();
  }

  // ======================================
  // INSERT CATEGORY
  // ======================================

  Future<void> insertCategory(String name) async {
    final db = await DBHelper.database;

    final category = Category(
      id: uuid.v4(),
      name: name,
      required: false,
      enabled: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ======================================
  // UPDATE CATEGORY
  // ======================================

  Future<void> updateCategory(Category category) async {
    final db = await DBHelper.database;

    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // ======================================
  // TOGGLE ENABLED
  // ======================================

  Future<void> toggleEnabled(Category category) async {

    final updated = category.copyWith(
      enabled: !category.enabled,
    );

    await updateCategory(updated);
  }

  // ======================================
  // TOGGLE REQUIRED
  // ======================================

  Future<void> toggleRequired(Category category) async {

    final updated = category.copyWith(
      required: !category.required,
    );

    await updateCategory(updated);
  }

  // ======================================
  // DELETE CATEGORY
  // ======================================

  Future<void> deleteCategory(String id) async {
    final db = await DBHelper.database;

    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}