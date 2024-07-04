import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pie_chart.dart';

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
              return SingleChildScrollView(
                child: Column(
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
                    SizedBox(height: 40),
                    Text(
                      'Weekly Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    PieChart(
                      data: _convertToPercentages(stats['weeklyExpenses']),
                    ),
                  ],
                ),
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
    Map<String, double> weeklyExpenses = {
      'Grocery': 0.0,
      'Entertainment': 0.0,
      'Other': 0.0,
    };

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));

    for (var transaction in transactions) {
      final amount = transaction['amount'] as double;
      final date = DateTime.parse(transaction['date']);
      final type = transaction['type'] as String;
      
      if (transaction['category'] == 'Income') {
        totalIncome += amount;
      } else if (transaction['category'] == 'Expense') {
        totalExpenses += amount;
        if (date.isAfter(oneWeekAgo) && date.isBefore(now)) {
          weeklyExpenses[type] = (weeklyExpenses[type] ?? 0.0) + amount;
        }
      }
    }

    return {
      'totalTransactions': totalTransactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'weeklyExpenses': weeklyExpenses,
    };
  }

  Map<String, double> _convertToPercentages(Map<String, double> expenses) {
    double total = expenses.values.reduce((a, b) => a + b);
    return expenses.map((key, value) => MapEntry(key, value / total));
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