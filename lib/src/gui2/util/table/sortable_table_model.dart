// Translation of pcgen.gui2.util.table.SortableTableModel

import 'package:flutter/foundation.dart';

/// Abstract sortable table model backed by a list of rows.
abstract class SortableTableModel<T> extends ChangeNotifier {
  final List<T> _rows = [];
  String? _sortColumn;
  bool _sortAscending = true;

  List<T> get rows => List.unmodifiable(_rows);

  void setData(List<T> data) {
    _rows.clear();
    _rows.addAll(data);
    _applySort();
    notifyListeners();
  }

  void addRow(T row) {
    _rows.add(row);
    _applySort();
    notifyListeners();
  }

  void removeRow(T row) {
    _rows.remove(row);
    notifyListeners();
  }

  void sortBy(String column, {bool ascending = true}) {
    _sortColumn = column;
    _sortAscending = ascending;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    if (_sortColumn != null) {
      _rows.sort((a, b) {
        final va = getColumnValue(a, _sortColumn!);
        final vb = getColumnValue(b, _sortColumn!);
        int cmp = _compareValues(va, vb);
        return _sortAscending ? cmp : -cmp;
      });
    }
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is Comparable) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }

  /// Override to return the value of [column] for a given [row].
  dynamic getColumnValue(T row, String column);

  /// Returns the number of columns.
  int get columnCount;

  /// Returns the column name at [index].
  String getColumnName(int index);

  /// Returns the value at [row] and [column].
  dynamic getValueAt(int row, int column);

  int get rowCount => _rows.length;
}
