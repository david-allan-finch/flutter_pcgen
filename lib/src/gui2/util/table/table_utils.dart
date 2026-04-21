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
