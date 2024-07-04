import 'dart:math';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final Map<String, double> data;

  PieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.cyan,
      Colors.blue,
      Colors.orange,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure the column size is minimized to content
      children: [
        Center(
          child: SizedBox(
            width: 240, // Slightly larger width
            height: 240, // Slightly larger height
            child: CustomPaint(
              painter: PieChartPainter(data: data, colors: colors),
              size: Size.infinite,
            ),
          ),
        ),
        SizedBox(height: 20), // Increase space between chart and legend
        Wrap(
          alignment: WrapAlignment.start, // Align legend to start
          spacing: 12.0, // Horizontal space between legends
          runSpacing: 8.0, // Vertical space between legends
          children: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colors[index],
                ),
                SizedBox(width: 6), // Increase space between color box and text
                Text('${entry.key}: ${(entry.value * 100).toStringAsFixed(0)}%'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2; // Start from the top

    for (int i = 0; i < data.length; i++) {
      final value = data.values.elementAt(i);
      final sweepAngle = value * 2 * pi;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Draw percentage text
      final percentage = (value * 100).toStringAsFixed(0) + '%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: percentage,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14, // Adjust font size if needed
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final middleAngle = startAngle + sweepAngle / 2;
      final textX = center.dx + (radius * 0.6) * cos(middleAngle) - textPainter.width / 2;
      final textY = center.dy + (radius * 0.6) * sin(middleAngle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
