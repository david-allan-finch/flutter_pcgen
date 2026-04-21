//
// Copyright 2008 (C) Connor Petty <mistercpp2000@gmail.com>
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
// Translation of pcgen.gui2.util.table.DefaultDynamicTableColumnModel

import 'package:flutter_pcgen/src/gui2/util/table/dynamic_table_column_model.dart';

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
