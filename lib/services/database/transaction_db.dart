import 'package:sqflite/sqflite.dart' as sql;
import '../../models/transaction.dart' as model; 
import 'database_helper.dart';

class TransactionDB {
  final _dbHelper = DatabaseHelper();

  Future<List<model.Transaction>> getTransactions() async {
    try {
      final db = await _dbHelper.database;
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
          id TEXT PRIMARY KEY, 
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category_name TEXT NOT NULL,
          category_icon TEXT NOT NULL,
          category_type TEXT NOT NULL,
          category_id TEXT NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC',);
      print('Retrieved ${maps.length} transactions from database');
      return List.generate(maps.length, (i) {
        return model.Transaction.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting transactions: $e');
      return []; 
    }
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('transactions', transaction.toMap());
      print('Transaction added successfully');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(model.Transaction transaction) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      print('Transaction deleted successfully');
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(model.Transaction transaction) async {  
    try {
      final db = await _dbHelper.database;
      await db.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      print('Transaction updated successfully');
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('transactions');
      print('All transactions deleted successfully');
    } catch (e) {
      print('Error deleting all transactions: $e');
      rethrow;
    }
  }
}