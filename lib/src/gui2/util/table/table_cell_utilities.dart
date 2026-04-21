//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
