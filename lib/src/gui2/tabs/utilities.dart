//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
