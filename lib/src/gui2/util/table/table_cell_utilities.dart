// Translation of pcgen.gui2.util.table.TableCellUtilities

import 'package:flutter/material.dart';

/// Utility methods for table cell rendering.
class TableCellUtilities {
  TableCellUtilities._();

  /// Returns a widget with appropriate background color for the given
  /// selected/focused state.
  static Widget cellWidget(
    BuildContext context,
    Widget child, {
    bool selected = false,
    bool focused = false,
  }) {
    final theme = Theme.of(context);
    Color? bg;
    Color? fg;
    if (selected) {
      bg = theme.colorScheme.primary;
      fg = theme.colorScheme.onPrimary;
    }
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(color: fg),
        child: child,
      ),
    );
  }

  /// Truncates text to fit in [maxWidth] pixels with ellipsis.
  static String truncateText(String text, double maxWidth, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    if (!painter.didExceedMaxLines) return text;
    // Binary search for the truncation point
    int lo = 0, hi = text.length;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      final sub = '${text.substring(0, mid)}…';
      final p = TextPainter(
        text: TextSpan(text: sub, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      if (p.didExceedMaxLines) {
        hi = mid - 1;
      } else {
        lo = mid;
      }
    }
    return '${text.substring(0, lo)}…';
  }
}
