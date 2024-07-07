import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        type TEXT,
        category TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN type TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE transactions ADD COLUMN synced INTEGER DEFAULT 0');
    }
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    transaction['synced'] = 0;
    int id = await db.insert('transactions', transaction);
    Fluttertoast.showToast(msg: 'Transaction inserted with id: $id');

    // Call sendDataToMongoDB after inserting the transaction
    await sendDataToMongoDB();

    return id;
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    List<Map<String, dynamic>> transactions = await db.query('transactions');
    Fluttertoast.showToast(msg: 'Fetched ${transactions.length} transactions');
    return transactions;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    final db = await database;
    List<Map<String, dynamic>> transactions = await db.query('transactions', where: 'synced = ?', whereArgs: [0]);
    Fluttertoast.showToast(msg: 'Fetched ${transactions.length} unsynced transactions');
    return transactions;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    int count = await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    Fluttertoast.showToast(msg: 'Deleted $count transaction(s) with id: $id');
    return count;
  }

  Future<int> updateTransaction(int id, Map<String, dynamic> transaction) async {
    final db = await database;
    transaction['synced'] = 0;
    int count = await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
    Fluttertoast.showToast(msg: 'Updated $count transaction(s) with id: $id');

    // Call sendDataToMongoDB after updating the transaction
    await sendDataToMongoDB();

    return count;
  }

  Future<void> markTransactionAsSynced(int id) async {
    final db = await database;
    await db.update(
      'transactions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    Fluttertoast.showToast(msg: 'Marked transaction as synced with id: $id');
  }

  Future<void> sendDataToMongoDB() async {
    final unsyncedTransactions = await getUnsyncedTransactions();

    for (var transaction in unsyncedTransactions) {
      try {
        final response = await http.post(
          Uri.parse('https://penny-wise-flutter.vercel.app/transactions/add'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(transaction),
        );

        if (response.statusCode == 201) {
          await markTransactionAsSynced(transaction['id']);
          print('Transaction sent to MongoDB and marked as synced with id: ${transaction['id']}');
          Fluttertoast.showToast(msg: 'Transaction sent to MongoDB and marked as synced with id: ${transaction['id']}');
        } else {
          print('Failed to send transaction to MongoDB: ${response.statusCode}');
          print('Response body: ${response.body}');
          Fluttertoast.showToast(msg: 'Failed to send transaction to MongoDB with id: ${transaction['id']}');
        }
      } catch (e) {
        print('Error sending transaction to MongoDB: $e');
        Fluttertoast.showToast(msg: 'Error sending transaction to MongoDB: $e');
      }
    }
  }
}
