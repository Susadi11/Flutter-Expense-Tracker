import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pie_chart.dart';
import 'home_screen.dart';
import 'profile.dart';

class StatisticsScreen extends StatefulWidget {
  final String userId;

  const StatisticsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedIndex = 1;

  final List<Color> expenseColors = [
    Color.fromARGB(255, 199, 129, 143),
    Color.fromARGB(255, 255, 204, 128),
    Color.fromARGB(255, 107, 94, 56),
    Color.fromARGB(255, 179, 205, 224),
    Color.fromARGB(255, 224, 187, 162),
  ];

  final List<Color> incomeColors = [
    Color.fromARGB(255, 167, 255, 186),
    Color.fromARGB(255, 179, 209, 255),
    Color.fromARGB(255, 220, 190, 255),
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
              return Center(child: Text('No records to display stats for this week.'));
            } else {
              final stats = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Week Statistics',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Expenses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RateWidget(rate: stats['expenseRate'], isExpense: true),
                      ],
                    ),
                    SizedBox(height: 20),
                    PieChart(
                      data: _convertToPercentages(stats['weeklyExpenses']),
                      colors: expenseColors,
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Incomes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RateWidget(rate: stats['incomeRate'], isExpense: false),
                      ],
                    ),
                    SizedBox(height: 20),
                    PieChart(
                      data: _convertToPercentages(stats['weeklyIncomes']),
                      colors: incomeColors,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
           setState(() {
             _selectedIndex = index;
           });
          if (index == 0) {
             Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId)),
             );
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Profile(userId: widget.userId)),
            );
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            label: 'Home',
          ),
        NavigationDestination(
      icon: Icon(Icons.bar_chart, color: Color(0xFFC2AA81)),
      label: 'Statistics',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline, color: Colors.grey),
      label: 'Profile',
    ),
  ],
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.white,
  indicatorColor: Colors.transparent,
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
),
    );
  }

  Future<Map<String, dynamic>> _calculateStatistics() async {
    final transactions = await DBHelper().getTransactions(widget.userId);

    if (transactions.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'incomePercentage': 0.0,
        'expensePercentage': 0.0,
        'weeklyExpenses': {
          'Grocery': 0.0,
          'Entertainment': 0.0,
          'Other': 0.0,
        },
        'weeklyIncomes': {
          'Salary': 0.0,
          'Loan': 0.0,
          'Other': 0.0,
        },
        'expenseRate': 0.0,
        'incomeRate': 0.0,
      };
    }

    int totalTransactions = 0;
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    double lastWeekExpenses = 0.0;
    double lastWeekIncome = 0.0;
    Map<String, double> weeklyExpenses = {
      'Grocery': 0.0,
      'Financial': 0.0,
      'Administrative': 0.0,
      'Entertainment': 0.0,
      'Other': 0.0,
    };
    Map<String, double> weeklyIncomes = {
      'Salary': 0.0,
      'Loan': 0.0,
      'Other': 0.0,
    };

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    final startOfLastWeek = startOfWeek.subtract(Duration(days: 7));

    for (var transaction in transactions) {
      final amount = transaction['amount'].toDouble();
      final date = DateTime.parse(transaction['date']);
      final type = transaction['type'] as String;

      if (date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)))) {
        totalTransactions++;
        
        if (transaction['category'] == 'Income') {
          totalIncome += amount;
          weeklyIncomes[type] = (weeklyIncomes[type] ?? 0.0) + amount;
        } else if (transaction['category'] == 'Expense') {
          totalExpenses += amount;
          weeklyExpenses[type] = (weeklyExpenses[type] ?? 0.0) + amount;
        }
      } else if (date.isAfter(startOfLastWeek.subtract(Duration(days: 1))) && date.isBefore(startOfWeek)) {
        if (transaction['category'] == 'Expense') {
          lastWeekExpenses += amount;
        } else if (transaction['category'] == 'Income') {
          lastWeekIncome += amount;
        }
      }
    }

     double total = totalIncome + totalExpenses;
    double incomePercentage = total > 0 ? (totalIncome / total) * 100 : 0;
    double expensePercentage = total > 0 ? (totalExpenses / total) * 100 : 0;

    // Calculate expense rate
    double expenseRate = _calculateRate(totalExpenses, lastWeekExpenses);

    // Calculate income rate
    double incomeRate = _calculateRate(totalIncome, lastWeekIncome);

    return {
      'totalTransactions': totalTransactions,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'incomePercentage': incomePercentage,
      'expensePercentage': expensePercentage,
      'weeklyExpenses': weeklyExpenses,
      'weeklyIncomes': weeklyIncomes,
      'expenseRate': expenseRate,
      'incomeRate': incomeRate,
    };
  }

  double _calculateRate(double currentValue, double lastWeekValue) {
    if (lastWeekValue != 0) {
      if (currentValue > lastWeekValue) {
        return ((currentValue - lastWeekValue) / lastWeekValue) * 100;
      } else {
        return -((lastWeekValue - currentValue) / lastWeekValue) * 100;
      }
    } else {
      return currentValue > 0 ? 100 : 0;
    }
  }

  Map<String, double> _convertToPercentages(Map<String, double> data) {
    double total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return data;
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

class RateWidget extends StatelessWidget {
  final double rate;
  final bool isExpense;

  const RateWidget({Key? key, required this.rate, required this.isExpense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    if (isExpense) {
      color = rate > 0 ? Colors.green : Colors.red;
      icon = rate > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      color = rate > 0 ? Colors.green : Colors.red;
      icon = rate > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    }
    
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          '${rate.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}