// lib/main.dart
import 'package:flutter/material.dart';
import 'add_transaction.dart'; // Import the new page

void main() {
  runApp(FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
      ),
      body: Center(
        child: Text('Welcome to Finance Tracker!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
