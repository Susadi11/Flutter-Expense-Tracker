import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pie_chart.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Color> expenseColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
  ];

  final List<Color> incomeColors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _calculateStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!['totalTransactions'] == 0) {
              return Center(child: Text('No records to display stats.'));
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
                      'Income vs Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    IncomeExpenseProbabilityBar(
                      incomePercentage: stats['incomePercentage'],
                      expensePercentage: stats['expensePercentage'],
                    ),
                    SizedBox(height: 40),
                    if (stats['weeklyExpenses'].isNotEmpty) ...[
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
                        colors: expenseColors,
                      ),
                      SizedBox(height: 40),
                    ],
                    if (stats['weeklyIncomes'].isNotEmpty) ...[
                      Text(
                        'Weekly Incomes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      PieChart(
                        data: _convertToPercentages(stats['weeklyIncomes']),
                        colors: incomeColors,
                      ),
                    ],
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

    if (transactions.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'incomePercentage': 0.0,
        'expensePercentage': 0.0,
        'weeklyExpenses': {},
        'weeklyIncomes': {},
      };
    }

    int totalTransactions = transactions.length;
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    Map<String, double> weeklyExpenses = {
      'Grocery': 0.0,
      'Entertainment': 0.0,
      'Other': 0.0,
    };
    Map<String, double> weeklyIncomes = {};

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));

    for (var transaction in transactions) {
      final amount = transaction['amount'] as double;
      final date = DateTime.parse(transaction['date']);
      final type = transaction['type'] as String;

      if (transaction['category'] == 'Income') {
        totalIncome += amount;
        if (date.isAfter(oneWeekAgo) && date.isBefore(now)) {
          weeklyIncomes[type] = (weeklyIncomes[type] ?? 0.0) + amount;
        }
      } else if (transaction['category'] == 'Expense') {
        totalExpenses += amount;
        if (date.isAfter(oneWeekAgo) && date.isBefore(now)) {
          weeklyExpenses[type] = (weeklyExpenses[type] ?? 0.0) + amount;
        }
      }
    }

    double total = totalIncome + totalExpenses;
    double incomePercentage = total > 0 ? (totalIncome / total) * 100 : 0;
    double expensePercentage = total > 0 ? (totalExpenses / total) * 100 : 0;

    return {
      'totalTransactions': totalTransactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'incomePercentage': incomePercentage,
      'expensePercentage': expensePercentage,
      'weeklyExpenses': weeklyExpenses,
      'weeklyIncomes': weeklyIncomes,
    };
  }

  Map<String, double> _convertToPercentages(Map<String, double> data) {
    double total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return {}; // Return an empty map if there's no data
    }
    return data.map((key, value) => MapEntry(key, value / total));
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

class IncomeExpenseProbabilityBar extends StatelessWidget {
  final double incomePercentage;
  final double expensePercentage;

  const IncomeExpenseProbabilityBar({
    Key? key,
    required this.incomePercentage,
    required this.expensePercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Income', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text('Expenses', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${incomePercentage.toStringAsFixed(1)}%'),
            Text('${expensePercentage.toStringAsFixed(1)}%'),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: incomePercentage.round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: expensePercentage.round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}