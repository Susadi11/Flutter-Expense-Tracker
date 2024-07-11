import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    // Example implementation of a simple line chart
    return Container(
      height: 200,
      padding: EdgeInsets.all(16.0),
      child: CustomPaint(
        painter: LineChartPainter(data: data),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final points = data.map((entry) {
      final date = entry['date'] as DateTime;
      final amount = entry['amount'] as double;
      final x = date.difference(DateTime.now()).inDays.toDouble();
      final y = amount;
      return Offset(x, y);
    }).toList();

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
