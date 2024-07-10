import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _transactions;
  String _selectedType = 'All';
  String _selectedSort = 'Newest First';
  String _selectedCategory = 'All';

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

  List<Map<String, dynamic>> _filterTransactionsByTypeAndCategory(
      List<Map<String, dynamic>> transactions,
      String type,
      String category) {
    return transactions.where((transaction) {
      if (type != 'All' && transaction['type'] != type) {
        return false;
      }
      if (category != 'All' && transaction['category'] != category) {
        return false;
      }
      return true;
    }).toList();
  }

  void _sortTransactionsByAmount(bool ascending) {
    _transactions.then((transactions) {
      List<Map<String, dynamic>> mutableTransactions = List.from(transactions);
      mutableTransactions.sort((a, b) {
        if (ascending) {
          return a['amount'].compareTo(b['amount']);
        } else {
          return b['amount'].compareTo(a['amount']);
        }
      });
      setState(() {
        _transactions = Future.value(mutableTransactions);
      });
    });
  }

  void _sortTransactionsByDate(bool newestFirst) {
    _transactions.then((transactions) {
      List<Map<String, dynamic>> mutableTransactions = List.from(transactions);
      mutableTransactions.sort((a, b) {
        if (newestFirst) {
          return b['date'].compareTo(a['date']);
        } else {
          return a['date'].compareTo(b['date']);
        }
      });
      setState(() {
        _transactions = Future.value(mutableTransactions);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
  children: [
    Expanded(
      flex: 3,
      child: DropdownButtonFormField<String>(
        value: _selectedSort,
        onChanged: (newValue) {
          setState(() {
            _selectedSort = newValue!;
            if (_selectedSort == 'Newest First') {
              _sortTransactionsByDate(true);
            } else if (_selectedSort == 'Oldest First') {
              _sortTransactionsByDate(false);
            } else if (_selectedSort == 'Amount (Ascending)') {
              _sortTransactionsByAmount(true);
            } else if (_selectedSort == 'Amount (Descending)') {
              _sortTransactionsByAmount(false);
            }
          });
        },
        items: <String>[
          'Newest First',
          'Oldest First',
          'Amount (Ascending)',
          'Amount (Descending)',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Sort By',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(Icons.arrow_drop_down),
        isExpanded: true,
        style: TextStyle(color: Colors.black, fontSize: 16),
        dropdownColor: Colors.white,
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      flex: 2,
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        onChanged: (newValue) {
          setState(() {
            _selectedCategory = newValue!;
          });
        },
        items: <String>['All', 'Income', 'Expense']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(Icons.arrow_drop_down),
        isExpanded: true,
        style: TextStyle(color: Colors.black, fontSize: 16),
        dropdownColor: Colors.white,
      ),
    ),
  ],
),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: <String>['All', 'Grocery', 'Entertainment', 'Other']
                  .map((String type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedType == type,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedType = selected ? type : 'All';
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder(
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
                    final filteredTransactions = _filterTransactionsByTypeAndCategory(
                        transactions, _selectedType, _selectedCategory);
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
                                Text('Category: ${filteredTransactions[index]['category']}'),
                                Text('Date: ${_formatDate(filteredTransactions[index]['date'])}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionPage(
                                      onAddTransaction: _refreshTransactions,
                                      transactionToEdit: filteredTransactions[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                onAddTransaction: _refreshTransactions,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(String date) {
    List<String> parts = date.split('T');
    List<String> dateParts = parts[0].split('-');
    return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
  }
}
