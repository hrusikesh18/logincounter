import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_values.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            value INTEGER
          )
        ''');
      },
    );
  }

  // Register a new user with error handling
  Future<void> registerUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    try {
      await db.insert(
        'user',
        {'username': username, 'password': hashedPassword, 'value': 0},
        conflictAlgorithm: ConflictAlgorithm.abort, // Aborts if username exists
      );
    } catch (e) {
      // username already exists
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        throw Exception('Username already exists');
      } else {
        throw e;
      }
    }
  }

  // Hash the password for storage
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Authenticate a user
  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);
    final result = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );
    return result.isNotEmpty;
  }

  // Get the current value of a user
  Future<int?> getUserValue(String username) async {
    final db = await database;
    final result = await db.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as int?;
    }
    return null;
  }

  // Save the value of a user
  Future<void> saveUserValue(String username, int value) async {
    final db = await database;
    await db.update(
      'user',
      {'value': value},
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
