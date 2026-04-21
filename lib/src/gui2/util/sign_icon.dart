//
// Copyright 2010 (C) Connor
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
