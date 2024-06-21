import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _transactions;
  String _selectedType = 'All'; // Default selected type

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

  List<Map<String, dynamic>> _filterTransactionsByType(
      List<Map<String, dynamic>> transactions, String type) {
    if (type == 'All') {
      return transactions;
    } else {
      return transactions
          .where((transaction) => transaction['type'] == type)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          DropdownButton<String>(
            value: _selectedType,
            onChanged: (newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
            items: <String>['All', 'Grocery', 'Entertainment', 'Other']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
            final filteredTransactions =
                _filterTransactionsByType(transactions, _selectedType);
            return ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
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
                    await DBHelper().deleteTransaction(filteredTransactions[index]['id']);
                    _refreshTransactions();
                  },
                  child: ListTile(
                    title: Text(filteredTransactions[index]['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: ${filteredTransactions[index]['amount']}'),
                        Text('Type: ${filteredTransactions[index]['type']}'),
                        Text('Date: ${_formatDate(filteredTransactions[index]['date'])}'), // Format date here
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDate(String date) {
    // Assuming date is in YYYY-MM-DDTHH:MM:SS format
    List<String> parts = date.split('T');
    List<String> dateParts = parts[0].split('-');
    if (dateParts.length == 3) {
      return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'; // DD/MM/YYYY format
    }
    return date; // Return as is if format is unexpected
  }
}
