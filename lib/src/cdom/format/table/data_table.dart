// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.format.table.DataTable

import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/format/table/table_column.dart';

/// Lookup type enumeration for row selection in a DataTable.
enum LookupType {
  /// Exact match lookup.
  exact,

  /// Last less-than-or-equal lookup (floor).
  lastLtEq,
}

/// A DataTable represents tabular data with typed columns.
/// All columns must be added before any rows.
class DataTable implements Loadable {
  String? _sourceUri;
  String? _name;
  final List<TableColumn> _columns = [];
  Map<Object, List<Object?>>? _dataByRow;

  /// Appends a new TableColumn. Must be called before addRow.
  void addColumn(TableColumn column) {
    if (_dataByRow != null && _dataByRow!.isNotEmpty) {
      throw StateError('Column may not be added after rows are added');
    }
    if (_columns.contains(column)) {
      throw ArgumentError('Column may not be duplicate: $column');
    }
    if (_columns.isEmpty) {
      // First column determines ordering.
      // For comparable first columns use a SplayTreeMap (sorted);
      // otherwise use a LinkedHashMap (insertion order).
      final fmt = column.getFormatManager();
      if (fmt != null && fmt.isComparable == true) {
        _dataByRow = {}; // TODO: TreeMap equivalent for comparable keys
      } else {
        _dataByRow = {};
      }
    }
    _columns.add(column);
  }

  TableColumn getColumn(int i) => _columns[i];

  /// Appends a new row. The row list must match the column count.
  void addRow(Object key, List<Object?> row) {
    _dataByRow ??= {};
    if (row.length != _columns.length) {
      throw ArgumentError(
          'Row length ${row.length} must match column count ${_columns.length}');
    }
    _dataByRow![key] = row;
  }

  /// Returns the FormatManager for the column with the given name.
  dynamic getFormat(String columnName) {
    return _columns
        .firstWhere((c) => c.getName() == columnName,
            orElse: () => throw ArgumentError(
                'Column Name must exist in the DataTable: $columnName'))
        .getFormatManager();
  }

  /// Looks up a value by row key (using the given lookup type) and column name.
  Object? lookup(LookupType lookupType, Object lookupValue, String resultingColumn) {
    final colIndex = _getColumnIndex(resultingColumn);
    if (colIndex == -1) {
      throw ArgumentError('Cannot find column named: $resultingColumn');
    }
    return _lookupByIndex(lookupType, lookupValue, colIndex);
  }

  /// Looks up a value by row key (using the given lookup type) and column index.
  Object? lookupByIndex(LookupType lookupType, Object lookupValue, int columnNumber) {
    return _lookupByIndex(lookupType, lookupValue, columnNumber);
  }

  Object? _lookupByIndex(LookupType lookupType, Object lookupValue, int columnNumber) {
    final row = _getRow(lookupType, lookupValue);
    return row?[columnNumber];
  }

  List<Object?>? _getRow(LookupType lookupType, Object lookupValue) {
    if (_dataByRow == null) return null;
    switch (lookupType) {
      case LookupType.exact:
        return _dataByRow![lookupValue];
      case LookupType.lastLtEq:
        // Find the last key <= lookupValue (requires Comparable keys).
        final keys = _dataByRow!.keys.whereType<Comparable>().toList()..sort();
        Object? bestKey;
        for (final k in keys) {
          if ((k as Comparable).compareTo(lookupValue) <= 0) {
            bestKey = k;
          } else {
            break;
          }
        }
        return bestKey != null ? _dataByRow![bestKey] : null;
    }
  }

  int _getColumnIndex(String name) {
    for (var i = 0; i < _columns.length; i++) {
      if (_columns[i].getName() == name) return i;
    }
    return -1;
  }

  int get columnCount => _columns.length;

  @override
  String getKeyName() => _name ?? '';

  @override
  String getDisplayName() => _name ?? '';

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  void setName(String name) => _name = name;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
