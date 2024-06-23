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
                    label: 'Number of Transactions This Week',
                    value: stats['transactionsThisWeek'].toString(),
                  ),
                  StatisticItem(
                    label: 'Total Income',
                    value: '\$${stats['totalIncome'].toStringAsFixed(2)}',
                  ),
                  StatisticItem(
                    label: 'Total Expenses',
                    value: '\$${stats['totalExpenses'].toStringAsFixed(2)}',
                  ),
                  // Add more StatisticItem widgets as needed
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
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    int transactionsThisWeek = 0;
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (var transaction in transactions) {
      final transactionDate = DateTime.parse(transaction['date']);
      if (transactionDate.isAfter(startOfWeek)) {
        transactionsThisWeek++;
      }
      final amount = transaction['amount'];
      if (transaction['type'] == 'Income') {
        totalIncome += amount;
      } else if (transaction['type'] == 'Expense') {
        totalExpenses += amount;
      }
    }

    return {
      'transactionsThisWeek': transactionsThisWeek,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
    };
  }
}

// Custom widget for displaying a single statistic item
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
