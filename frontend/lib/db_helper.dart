import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      version: 3,
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
        synced INTEGER DEFAULT 0,
        mongoId TEXT,
        userId TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN userId TEXT');
    }
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction, String userId) async {
  final db = await database;
  transaction['synced'] = 0;
  transaction['userId'] = userId;
  int id = await db.insert('transactions', transaction);
  Fluttertoast.showToast(msg: 'Transaction inserted locally with id: $id');

  if (await isConnected()) {
    await sendTransactionToMongoDB(transaction, id);
  }

  return id;
}

  Future<void> sendTransactionToMongoDB(Map<String, dynamic> transaction, int localId) async {
    try {
      final response = await http.post(
        Uri.parse('https://penny-wise-flutter.vercel.app/transactions/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(transaction),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String mongoId = responseBody['_id'];
        await updateMongoId(localId, mongoId);
        await markTransactionAsSynced(localId);
        Fluttertoast.showToast(msg: 'Transaction synced with MongoDB');
      } else {
        Fluttertoast.showToast(msg: 'Failed to sync transaction with MongoDB');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error syncing transaction with MongoDB: $e');
    }
  }

  Future<void> updateMongoId(int localId, String mongoId) async {
    final db = await database;
    await db.update(
      'transactions',
      {'mongoId': mongoId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
  final db = await database;
  List<Map<String, dynamic>> localTransactions = await db.query(
    'transactions',
    where: 'userId = ?',
    whereArgs: [userId],
  );

  if (await isConnected()) {
    await syncWithMongoDB(userId);
    localTransactions = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Fluttertoast.showToast(msg: 'Fetched ${localTransactions.length} transactions');
  return localTransactions;
}

Future<void> syncWithMongoDB(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('https://penny-wise-flutter.vercel.app/transactions?userId=$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> mongoTransactions = jsonDecode(response.body);
      await _updateLocalDatabase(mongoTransactions, userId);
    } else {
      Fluttertoast.showToast(msg: 'Failed to sync with MongoDB');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error syncing with MongoDB: $e');
  }
}

  Future<void> _updateLocalDatabase(List<dynamic> mongoTransactions, String userId) async {
  final db = await database;
  await db.transaction((txn) async {
    for (var transaction in mongoTransactions) {
      String mongoId = transaction['_id'];
      List<Map> existingTransactions = await txn.query(
        'transactions',
        where: 'mongoId = ? AND userId = ?',
        whereArgs: [mongoId, userId],
      );

      if (existingTransactions.isEmpty) {
        // Insert new transaction
        await txn.insert('transactions', {
          'title': transaction['title'],
          'amount': transaction['amount'],
          'date': transaction['date'],
          'type': transaction['type'],
          'category': transaction['category'],
          'synced': 1,
          'mongoId': mongoId,
          'userId': userId,
        });
      } else {
        // Update existing transaction
        await txn.update(
          'transactions',
          {
            'title': transaction['title'],
            'amount': transaction['amount'],
            'date': transaction['date'],
            'type': transaction['type'],
            'category': transaction['category'],
            'synced': 1,
          },
          where: 'mongoId = ? AND userId = ?',
          whereArgs: [mongoId, userId],
        );
      }
    }
  });
}

  Future<bool> deleteTransaction(int id, String userId) async {
    final db = await database;
    Map<String, dynamic>? transaction = (await db.query(
      'transactions',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    )).firstOrNull;

    if (transaction == null) {
      Fluttertoast.showToast(msg: 'Transaction not found');
      return false;
    }

    int count = await db.delete('transactions', where: 'id = ? AND userId = ?', whereArgs: [id, userId]);
    
    if (count > 0) {
      Fluttertoast.showToast(msg: 'Deleted transaction locally with id: $id');
      
      if (await isConnected() && transaction['mongoId'] != null) {
        await deleteTransactionFromMongoDB(transaction['mongoId']);
      }
      
      return true;
    } else {
      Fluttertoast.showToast(msg: 'Failed to delete transaction locally');
      return false;
    }
  }

  Future<void> deleteTransactionFromMongoDB(String mongoId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://penny-wise-flutter.vercel.app/transactions/$mongoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Transaction deleted from MongoDB');
      } else {
        Fluttertoast.showToast(msg: 'Failed to delete transaction from MongoDB');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting transaction from MongoDB: $e');
    }
  }

  Future<int> updateTransaction(int id, Map<String, dynamic> transaction, String userId) async {
    final db = await database;
    transaction['synced'] = 0;
    int count = await db.update(
      'transactions',
      transaction,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
    
    if (count > 0) {
      Fluttertoast.showToast(msg: 'Updated transaction locally with id: $id');
      
      if (await isConnected()) {
        await updateTransactionInMongoDB(id, transaction, userId);
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to update transaction locally');
    }

    return count;
  }

  Future<void> updateTransactionInMongoDB(int localId, Map<String, dynamic> transaction, String userId) async {
    final db = await database;
    List<Map> result = await db.query(
      'transactions',
      columns: ['mongoId'],
      where: 'id = ? AND userId = ?',
      whereArgs: [localId, userId],
    );

    if (result.isNotEmpty && result.first['mongoId'] != null) {
      String mongoId = result.first['mongoId'];
      try {
        final response = await http.put(
          Uri.parse('https://penny-wise-flutter.vercel.app/transactions/$mongoId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(transaction),
        );

        if (response.statusCode == 200) {
          await markTransactionAsSynced(localId);
          Fluttertoast.showToast(msg: 'Transaction updated in MongoDB');
        } else {
          Fluttertoast.showToast(msg: 'Failed to update transaction in MongoDB');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error updating transaction in MongoDB: $e');
      }
    }
  }

  Future<void> markTransactionAsSynced(int id) async {
    final db = await database;
    await db.update(
      'transactions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncUnsyncedTransactions(String userId) async {
    if (await isConnected()) {
      final db = await database;
      List<Map<String, dynamic>> unsyncedTransactions = await db.query(
        'transactions',
        where: 'synced = ? AND userId = ?',
        whereArgs: [0, userId],
      );

      for (var transaction in unsyncedTransactions) {
        if (transaction['mongoId'] == null) {
          await sendTransactionToMongoDB(transaction, transaction['id']);
        } else {
          await updateTransactionInMongoDB(transaction['id'], transaction, userId);
        }
      }
    }
  }
}