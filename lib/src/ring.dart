import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ActivityProgressRing extends StatelessWidget {
  const ActivityProgressRing({
    Key? key,
    required this.percent,
    required this.backgroundColor,
    required this.colors,
    this.height = 168,
    this.radius,
    this.strokeWidth = 20,
  }) : super(key: key);
  final double percent;
  final Color backgroundColor;
  final List<Color> colors;
  final double height;
  final double? radius;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: percent),
          curve: Curves.easeOutQuad,
          duration: Duration(seconds: (percent ~/ 100) + 3),
          builder: (context, double percent, child) {
            return CustomPaint(
              size: Size(height, height),
              painter: RingPainter(
                percent: percent,
                backgroundColor: backgroundColor,
                colors: colors,
                radius: radius,
                strokeWidth: strokeWidth,
              ),
              child: child,
            );
          },
        ),
      ],
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter({
    required this.percent,
    required this.backgroundColor,
    required this.colors,
    double? radius,
    this.strokeWidth = 20,
    this.showBackGround = false,
  }) : _radius = radius;

  final double percent;
  final Color backgroundColor;
  final List<Color> colors;
  final double? _radius;
  final double strokeWidth;
  final bool showBackGround;
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final radius = _radius ?? (min(width, height)) / 2;
    final center = Offset(width / 2, height / 2);

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );
    final remainder = percent % 100;

    final startAngle = _degToRad(-90);
    final sweepAngle = ((percent % 100) / 100) * pi * 2;
    final stops = [0.8, 1.0];

    final paint = Paint()
      ..color = colors[0]
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradient = SweepGradient(
      tileMode: TileMode.mirror,
      startAngle: startAngle,
      endAngle: sweepAngle,
      stops: stops,
      colors: colors,
      transform: GradientRotation(startAngle),
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        rect,
      )
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = const Color(0xff444444).withOpacity(0.2)
      ..strokeWidth = strokeWidth - 5
      ..style = PaintingStyle.stroke
      ..imageFilter = ImageFilter.blur(
        sigmaX: 4,
        sigmaY: 4,
      )
      ..strokeCap = StrokeCap.round;

    if (percent == 100) {
      canvas.drawCircle(center, radius, paint);
    } else if (percent < 100) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas
        ..drawCircle(center, radius, backgroundPaint)
        ..drawArc(
          rect,
          startAngle,
          sweepAngle,
          false,
          paint,
        );
    } else if (percent > 100 && remainder < 20) {
      final startAngle100 = startAngle - 1.0;
      final sweepAngle100 = sweepAngle + 1.0;

      final gradient = SweepGradient(
        tileMode: TileMode.mirror,
        startAngle: startAngle100,
        endAngle: sweepAngle100,
        stops: stops,
        colors: colors,
        transform: GradientRotation(startAngle100),
      );

      gradientPaint.shader = gradient.createShader(
        rect,
      );

      canvas
        ..drawCircle(center, radius, paint)
        ..drawArc(rect, _degToRad(-85), sweepAngle, false, shadowPaint)
        ..drawArc(
          rect,
          startAngle100,
          sweepAngle100,
          false,
          gradientPaint,
        );
    } else if (percent > 100 && (remainder > 19 && remainder < 90)) {
      canvas
        ..drawCircle(center, radius, paint)
        ..drawArc(rect, _degToRad(-85), sweepAngle, false, shadowPaint)
        ..drawArc(
          rect,
          startAngle,
          sweepAngle,
          false,
          gradientPaint,
        )
        ..drawArc(
          rect,
          _degToRad(-90),
          _degToRad(-1),
          false,
          paint,
        );
    } else if (percent > 100 && remainder > 89) {
      final startAngle100 = startAngle + 1.5;
      final sweepAngle100 = sweepAngle - 1.5;

      final gradient = SweepGradient(
        tileMode: TileMode.mirror,
        startAngle: startAngle100,
        endAngle: sweepAngle100,
        stops: stops,
        colors: colors,
        transform: GradientRotation(startAngle100),
      );

      gradientPaint.shader = gradient.createShader(
        rect,
      );
      canvas
        ..drawCircle(center, radius, paint)
        ..drawArc(
          rect,
          startAngle100,
          sweepAngle100,
          false,
          gradientPaint,
        );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }

  double _degToRad(double degree) => degree * pi / 180;
}
