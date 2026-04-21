// Translation of pcgen.gui3.utilty.ColorUtilty (note: original typo preserved)

import 'package:flutter/material.dart';

/// Color utility helpers used by the gui3 preference panels.
class ColorUtilty {
  ColorUtilty._();

  /// Convert a Color to a CSS hex string (#RRGGBB).
  static String toHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  /// Parse a CSS hex string (#RRGGBB or RRGGBB) to a Color.
  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return Colors.black;
  }

  /// Returns a contrasting foreground color (black or white) for [background].
  static Color contrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
