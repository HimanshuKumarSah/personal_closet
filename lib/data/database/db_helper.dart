import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createDB(Database db, int version) async {

    // CLOTHING TABLE
    await db.execute('''
    CREATE TABLE clothing(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      color TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      tags TEXT,
      createdAt TEXT NOT NULL
    )
    ''');

    // OUTFITS TABLE
    await db.execute('''
    CREATE TABLE outfits(
      id TEXT PRIMARY KEY,
      shirtId TEXT NOT NULL,
      pantId TEXT NOT NULL,
      shoesId TEXT NOT NULL,
      jacketId TEXT,
      capId TEXT,
      createdAt TEXT NOT NULL
    )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE outfits ADD COLUMN jacketId TEXT");
      await db.execute(
          "ALTER TABLE outfits ADD COLUMN capId TEXT");
    }
  }
}