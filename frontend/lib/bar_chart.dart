import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final Map<String, double> data;

  BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.keys.map((category) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${data[category]!.toStringAsFixed(1)}'),
              Container(
                width: 20,
                height: data[category]! * 10, // scale the height for display
                color: Colors.blue,
              ),
              SizedBox(height: 8),
              Text(category),
            ],
          );
        }).toList(),
      ),
    );
  }
}
