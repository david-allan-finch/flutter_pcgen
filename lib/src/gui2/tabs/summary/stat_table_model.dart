// Translation of pcgen.gui2.tabs.summary.StatTableModel

import 'package:flutter/foundation.dart';

/// Table model for the ability score (stat) table on the Summary tab.
class StatTableModel extends ChangeNotifier {
  static const List<String> columnNames = [
    'Stat', 'Base', 'Race', 'Other', 'Total', 'Mod',
  ];

  final List<_StatRow> _rows = [];

  int get rowCount => _rows.length;
  int get columnCount => columnNames.length;

  dynamic getValue(int row, int col) {
    if (row < 0 || row >= _rows.length) return null;
    final r = _rows[row];
    switch (col) {
      case 0: return r.name;
      case 1: return r.base;
      case 2: return r.racial;
      case 3: return r.other;
      case 4: return r.total;
      case 5: return r.modifier;
      default: return null;
    }
  }

  bool isCellEditable(int row, int col) => col == 1; // only Base is editable

  void setBase(int row, int value) {
    if (row < 0 || row >= _rows.length) return;
    _rows[row].base = value;
    notifyListeners();
  }

  void setData(List<({String name, int base, int racial, int other})> data) {
    _rows.clear();
    for (final d in data) {
      _rows.add(_StatRow(
        name: d.name,
        base: d.base,
        racial: d.racial,
        other: d.other,
      ));
    }
    notifyListeners();
  }

  void clear() {
    _rows.clear();
    notifyListeners();
  }
}

class _StatRow {
  final String name;
  int base;
  final int racial;
  final int other;

  _StatRow({
    required this.name,
    required this.base,
    required this.racial,
    required this.other,
  });

  int get total => base + racial + other;
  int get modifier => (total - 10) ~/ 2;
}
