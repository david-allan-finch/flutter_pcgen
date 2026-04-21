// Translation of pcgen.gui2.util.table.DefaultDynamicTableColumnModel

import 'dynamic_table_column_model.dart';

/// Default implementation of DynamicTableColumnModel.
class DefaultDynamicTableColumnModel implements DynamicTableColumnModel {
  final List<_ColumnEntry> _columns = [];
  final List<dynamic> _listeners = [];

  void addColumn(dynamic column, {bool visible = true}) {
    _columns.add(_ColumnEntry(column, visible));
  }

  @override
  void setColumnVisible(dynamic column, bool visible) {
    for (final entry in _columns) {
      if (entry.column == column) {
        entry.visible = visible;
        _notifyListeners();
        return;
      }
    }
  }

  @override
  bool isColumnVisible(dynamic column) {
    for (final entry in _columns) {
      if (entry.column == column) return entry.visible;
    }
    return false;
  }

  @override
  List<dynamic> getColumns({bool includeHidden = false}) {
    return _columns
        .where((e) => includeHidden || e.visible)
        .map((e) => e.column)
        .toList();
  }

  @override
  void addColumnModelListener(dynamic listener) => _listeners.add(listener);

  @override
  void removeColumnModelListener(dynamic listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final l in _listeners) {
      try {
        l.columnMarginChanged(null);
      } catch (_) {}
    }
  }
}

class _ColumnEntry {
  final dynamic column;
  bool visible;
  _ColumnEntry(this.column, this.visible);
}
