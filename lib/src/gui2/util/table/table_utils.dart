//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.table.TableUtils

import 'package:flutter/material.dart';

/// Utility methods for table configuration and setup.
class TableUtils {
  TableUtils._();

  /// Creates a standard DataTable from a list of column names and row data.
  static DataTable buildTable({
    required List<String> columns,
    required List<List<dynamic>> rows,
    int? sortColumnIndex,
    bool sortAscending = true,
    void Function(int columnIndex, bool ascending)? onSort,
  }) {
    return DataTable(
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: columns
          .asMap()
          .entries
          .map((e) => DataColumn(
                label: Text(e.value),
                onSort: onSort != null
                    ? (idx, asc) => onSort(idx, asc)
                    : null,
              ))
          .toList(),
      rows: rows
          .map((row) => DataRow(
                cells: row
                    .map((cell) => DataCell(
                          Text(cell?.toString() ?? ''),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  /// Sets up uniform column widths.
  static List<double> evenColumnWidths(double totalWidth, int columnCount) {
    if (columnCount == 0) return [];
    final width = totalWidth / columnCount;
    return List.filled(columnCount, width);
  }
}
