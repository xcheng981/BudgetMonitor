import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Fetch data samples
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    await deleteDatabase(path);  

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            user_name TEXT,
            avatar_path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_email TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (user_email) REFERENCES users (email)
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            type TEXT NOT NULL,
            is_custom_icon INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await _insertSampleUsers(db);
      },
    );
  }

  // Fetch user info (for login）
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['email', 'password', 'user_name', 'avatar_path'],
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isEmpty) return null;
    
    return {
      'email': result.first['email'] as String,
      'password': result.first['password'] as String,
      'user_name': result.first['user_name'] as String?,
      'avatar_path': result.first['avatar_path'] as String?,
    };
  }

  // Insert sample user info
  Future<void> _insertSampleUsers(Database db) async {
    final sampleUsers = [
      {
        'email': '123@123.com',
        'password': '123',
        'user_name': 'Test User',
        'avatar_path': null,
      },
      {
        'email': 'demo@example.com',
        'password': 'Demo123!',
        'user_name': 'Demo User',
        'avatar_path': null,
      },
    ];

    for (var user in sampleUsers) {
      await db.insert('users', user);
    }
    print('Sample users inserted successfully');
  }

  // Fetch user info through email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['email', 'password', 'user_name', 'avatar_path'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Create new user
  Future<void> createUser(String email, String password, {String? userName, String? avatarPath}) async {
    final db = await database;
    await db.insert('users', {
      'email': email,
      'password': password,
      'user_name': userName,
      'avatar_path': avatarPath,
    });
  }

  // Update user info
  Future<bool> updateUserProfile(String email, {
    String? newEmail,
    String? newPassword,
    String? userName,
    String? avatarPath,
  }) async {
    try {
      final db = await database;
      final updates = <String, dynamic>{};
      
      if (newEmail != null) updates['email'] = newEmail;
      if (newPassword != null) updates['password'] = newPassword;
      if (userName != null) updates['user_name'] = userName;
      if (avatarPath != null) updates['avatar_path'] = avatarPath;
      
      if (updates.isEmpty) return true;

      final count = await db.update(
        'users',
        updates,
        where: 'email = ?',
        whereArgs: [email],
      );
      
      print('User profile updated successfully: $updates');
      return count > 0;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> emailExists(String email) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  return result.isNotEmpty; 
}

  Future<int> insertRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('records', record);
  }

  Future<List<Map<String, dynamic>>> getRecords(String userEmail) async {
    final db = await database;
    return await db.query(
      'records',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'date DESC',
    );
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRecord(int id, Map<String, dynamic> record) async {
    final db = await database;
    await db.update(
      'records',
      record,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getRecordsInDateRange(
    String userEmail,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.query(
      'records',
      where: 'user_email = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userEmail,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>> getRecordStats(String userEmail) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income
      FROM records
      WHERE user_email = ?
    ''', [userEmail]);
    
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getRecordsByCategory(String categoryId) async {
    final db = await database;
    return await db.query(
      'records',
      where: 'category = ?',
      whereArgs: [categoryId],
    );
  }

  Future<void> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    await db.insert('categories', {
      'id': category['id'],
      'name': category['name'],
      'icon': category['icon'],
      'type': category['type'],
      'is_custom_icon': category['isCustomIcon'] ? 1 : 0,
    });
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> category) async {
    final db = await database;
    await db.update(
      'categories',
      {
        'name': category['name'],
        'icon': category['icon'],
        'type': category['type'],
        'is_custom_icon': category['isCustomIcon'] ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'records',
        where: 'category = ?',
        whereArgs: [categoryId],
      );
      
      await txn.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [categoryId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCustomCategories() async {
    final db = await database;
    final result = await db.query('categories');
    return result.map((category) => {
      ...category,
      'isCustomIcon': category['is_custom_icon'] == 1,
    }).toList();
  }
}