import 'package:flutter/material.dart';
import 'add_transaction.dart'; // Ensure this import is present
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
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactions = DBHelper().getTransactions();
    });
  }

  void _refreshTransactions() {
    _loadTransactions();
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
                    onAddTransaction: _refreshTransactions, // Pass the callback
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
                return ListTile(
                  title: Text(transactions[index]['title']),
                  subtitle: Text('Amount: \$${transactions[index]['amount']}'),
                  trailing: Text(transactions[index]['date']),
                  onLongPress: () async {
                    await DBHelper().deleteTransaction(transactions[index]['id']);
                    _loadTransactions();
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
