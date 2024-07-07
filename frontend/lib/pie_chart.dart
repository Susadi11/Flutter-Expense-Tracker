import 'dart:math';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  PieChart({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: PieChartPainter(data: data, colors: colors),
              size: Size.infinite,
            ),
          ),
        ),
        SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 12.0,
          runSpacing: 8.0,
          children: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colors[index % colors.length],
                ),
                SizedBox(width: 6),
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

    double startAngle = -pi / 2;

    data.entries.toList().asMap().forEach((index, entry) {
      final sweepAngle = entry.value * 2 * pi;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[index % colors.length];

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Only draw percentage if it's not 0%
      if (entry.value > 0) {
        final percentage = (entry.value * 100).toStringAsFixed(0) + '%';
        final textPainter = TextPainter(
          text: TextSpan(
            text: percentage,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
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
      }

      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}