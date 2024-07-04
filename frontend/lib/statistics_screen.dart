import 'package:flutter/material.dart';
import 'db_helper.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _calculateStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            } else {
              final stats = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  StatisticItem(
                    label: 'Total Transactions',
                    value: stats['totalTransactions'].toString(),
                  ),
                  StatisticItem(
                    label: 'Total Income',
                    value: '\$${stats['totalIncome'].toStringAsFixed(2)}',
                  ),
                  StatisticItem(
                    label: 'Total Expenses',
                    value: '\$${stats['totalExpenses'].toStringAsFixed(2)}',
                  ),
                  StatisticItem(
                    label: 'Net Balance',
                    value: '\$${(stats['totalIncome'] - stats['totalExpenses']).toStringAsFixed(2)}',
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateStatistics() async {
    final transactions = await DBHelper().getTransactions();
    
    int totalTransactions = transactions.length;
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (var transaction in transactions) {
      final amount = transaction['amount'] as double;
      if (transaction['category'] == 'Income') {
        totalIncome += amount;
      } else if (transaction['category'] == 'Expense') {
        totalExpenses += amount;
      }
    }

    return {
      'totalTransactions': totalTransactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
    };
  }
}

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;

  const StatisticItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}