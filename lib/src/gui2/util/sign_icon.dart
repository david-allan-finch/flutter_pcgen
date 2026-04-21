// Translation of pcgen.gui2.util.SignIcon

import 'package:flutter/material.dart';

enum Sign { plus, minus }

/// A small 9×9 icon that draws either a plus or minus sign in black.
class SignIcon extends StatelessWidget {
  static const double _size = 9.0;

  final Sign sign;

  const SignIcon({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(_size, _size),
      painter: _SignPainter(sign),
    );
  }
}

class _SignPainter extends CustomPainter {
  final Sign sign;

  const _SignPainter(this.sign);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Horizontal bar
    canvas.drawRect(const Rect.fromLTWH(0, 3, 9, 3), paint);

    // Vertical bar (only for plus)
    if (sign == Sign.plus) {
      canvas.drawRect(const Rect.fromLTWH(3, 0, 3, 9), paint);
    }
  }

  @override
  bool shouldRepaint(_SignPainter old) => old.sign != sign;
}
