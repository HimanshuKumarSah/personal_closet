import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ai_closet.db');
    return _database!;
  }

  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createDB(Database db, int version) async {

    // ===============================
    // CATEGORIES TABLE
    // ===============================
    await db.execute('''
    CREATE TABLE categories(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      required INTEGER NOT NULL,
      enabled INTEGER NOT NULL,
      createdAt TEXT NOT NULL
    )
    ''');

    // ===============================
    // CLOTHING TABLE
    // ===============================
    await db.execute('''
    CREATE TABLE clothing(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      categoryId TEXT NOT NULL,
      color TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      tags TEXT,
      createdAt TEXT NOT NULL
    )
    ''');

    // ===============================
    // OUTFITS TABLE
    // ===============================
    await db.execute('''
    CREATE TABLE outfits(
      id TEXT PRIMARY KEY,
      createdAt TEXT NOT NULL
    )
    ''');

    // ===============================
    // OUTFIT ITEMS TABLE
    // ===============================
    await db.execute('''
    CREATE TABLE outfit_items(
      id TEXT PRIMARY KEY,
      outfitId TEXT NOT NULL,
      clothingId TEXT NOT NULL,
      categoryId TEXT NOT NULL
    )
    ''');

    await _insertDefaultCategories(db);
  }

  // ============================================
  // DATABASE MIGRATION
  // ============================================

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 3) {

      // ------------------------------
      // CREATE CATEGORIES TABLE
      // ------------------------------
      await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        required INTEGER NOT NULL,
        enabled INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
      ''');

      // ------------------------------
      // CREATE OUTFIT ITEMS TABLE
      // ------------------------------
      await db.execute('''
      CREATE TABLE IF NOT EXISTS outfit_items(
        id TEXT PRIMARY KEY,
        outfitId TEXT NOT NULL,
        clothingId TEXT NOT NULL,
        categoryId TEXT NOT NULL
      )
      ''');

      await _insertDefaultCategories(db);

      // ------------------------------
      // MIGRATE CLOTHING TABLE
      // ------------------------------
      await db.execute('''
      ALTER TABLE clothing RENAME TO clothing_old
      ''');

      await db.execute('''
      CREATE TABLE clothing(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        color TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        tags TEXT,
        createdAt TEXT NOT NULL
      )
      ''');

      // Get category IDs
      final categories = await db.query('categories');

      String shirtId = categories.firstWhere((c) => c['name'] == 'Shirts')['id'] as String;
      String pantId = categories.firstWhere((c) => c['name'] == 'Pants')['id'] as String;
      String shoesId = categories.firstWhere((c) => c['name'] == 'Shoes')['id'] as String;
      String jacketId = categories.firstWhere((c) => c['name'] == 'Jackets')['id'] as String;
      String capId = categories.firstWhere((c) => c['name'] == 'Caps')['id'] as String;

      final oldClothing = await db.query('clothing_old');

      for (var item in oldClothing) {

        String categoryName = item['category'] as String;

        String categoryId = shirtId;

        if (categoryName == "shirts") categoryId = shirtId;
        if (categoryName == "pants") categoryId = pantId;
        if (categoryName == "shoes") categoryId = shoesId;
        if (categoryName == "jackets") categoryId = jacketId;
        if (categoryName == "caps") categoryId = capId;

        await db.insert('clothing', {
          'id': item['id'],
          'name': item['name'],
          'categoryId': categoryId,
          'color': item['color'],
          'imagePath': item['imagePath'],
          'tags': item['tags'],
          'createdAt': item['createdAt']
        });
      }

      await db.execute("DROP TABLE clothing_old");

      // ------------------------------
      // MIGRATE OUTFITS
      // ------------------------------

      final oldOutfits = await db.query('outfits');

      for (var outfit in oldOutfits) {

        String outfitId = outfit['id'] as String;

        final items = {
          shirtId: outfit['shirtId'],
          pantId: outfit['pantId'],
          shoesId: outfit['shoesId'],
          jacketId: outfit['jacketId'],
          capId: outfit['capId']
        };

        for (var entry in items.entries) {

          if (entry.value == null) continue;

          await db.insert('outfit_items', {
            'id': const Uuid().v4(),
            'outfitId': outfitId,
            'clothingId': entry.value,
            'categoryId': entry.key
          });
        }
      }

      await db.execute("DROP TABLE outfits");

      await db.execute('''
      CREATE TABLE outfits(
        id TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL
      )
      ''');
    }
  }

  // ============================================
  // INSERT DEFAULT CATEGORIES
  // ============================================

  static Future<void> _insertDefaultCategories(Database db) async {

    final uuid = const Uuid();

    final now = DateTime.now().toIso8601String();

    await db.insert('categories', {
      'id': uuid.v4(),
      'name': 'Shirts',
      'required': 0,
      'enabled': 1,
      'createdAt': now
    });

    await db.insert('categories', {
      'id': uuid.v4(),
      'name': 'Pants',
      'required': 0,
      'enabled': 1,
      'createdAt': now
    });

    await db.insert('categories', {
      'id': uuid.v4(),
      'name': 'Shoes',
      'required': 1,
      'enabled': 1,
      'createdAt': now
    });

    await db.insert('categories', {
      'id': uuid.v4(),
      'name': 'Jackets',
      'required': 0,
      'enabled': 1,
      'createdAt': now
    });

    await db.insert('categories', {
      'id': uuid.v4(),
      'name': 'Caps',
      'required': 0,
      'enabled': 0,
      'createdAt': now
    });
  }
}