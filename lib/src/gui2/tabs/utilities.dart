// Translation of pcgen.gui2.tabs.Utilities

import 'package:flutter/material.dart';

/// Utility methods for building tab UI elements.
final class Utilities {
  Utilities._();

  /// Creates a sign button (plus or minus) widget.
  static Widget createSignButton(
    Sign sign, {
    required VoidCallback? onPressed,
  }) {
    final label = sign == Sign.positive ? '+' : '−';
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 0),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  /// Returns a column definition for use in DataTable / custom table widgets.
  static TableColumnDef createTableColumn(
    int index,
    String headerValue, {
    bool resizable = true,
  }) {
    final resolved =
        headerValue.startsWith('in_') ? headerValue : headerValue;
    return TableColumnDef(
      index: index,
      header: resolved,
      resizable: resizable,
    );
  }
}

/// Represents the sign direction for a sign button.
enum Sign { positive, negative }

/// Lightweight description of a table column.
class TableColumnDef {
  final int index;
  final String header;
  final bool resizable;

  const TableColumnDef({
    required this.index,
    required this.header,
    required this.resizable,
  });
}
