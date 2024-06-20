import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = _loadTransactions();
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    return await DBHelper().getTransactions();
  }

  void _refreshTransactions() {
    setState(() {
      _transactions = _loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTransactionPage(
                    onAddTransaction: _refreshTransactions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _transactions,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(child: Text('No transactions added yet.'));
          } else {
            final transactions = snapshot.data as List<Map<String, dynamic>>;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.red),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete Transaction'),
                        content: Text('Are you sure you want to delete this transaction?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await DBHelper().deleteTransaction(transactions[index]['id']);
                    _refreshTransactions();
                  },
                  child: ListTile(
                    title: Text(transactions[index]['title']),
                    subtitle: Text(
                      'Amount: \$${transactions[index]['amount']} - Type: ${transactions[index]['type']}',
                    ),
                    trailing: Text(transactions[index]['date']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}