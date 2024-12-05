import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/hour_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'complementary_hours.db');

    // Verificar se o banco já existe antes de abri-lo
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE hours (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          hours INTEGER,
          date TEXT,
          proofPath TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          // Exemplo de adição de uma coluna
          await db.execute('ALTER TABLE hours ADD COLUMN newColumnName TEXT');
        }
      },
    );
  }

  Future<int> insertHour(HourEntry entry) async {
    final db = await database;
    return db.insert('hours', entry.toMap());
  }

  Future<List<HourEntry>> getAllHours() async {
    final db = await database;
    final maps = await db.query('hours');
    return maps.map((map) => HourEntry.fromMap(map)).toList();
  }

  Future<int> updateHour(HourEntry entry) async {
    final db = await database;
    return db.update(
      'hours',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteHour(int id) async {
    final db = await database;
    return db.delete(
      'hours',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllHours() async {
    final db = await database;
    await db.delete('hours');
  }
}
