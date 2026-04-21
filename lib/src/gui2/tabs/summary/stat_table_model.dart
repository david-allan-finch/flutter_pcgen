//
// Copyright 2010 (C) Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.summary.StatTableModel

import 'package:flutter/foundation.dart';

/// Table model for the ability score (stat) table on the Summary tab.
class StatTableModel extends ChangeNotifier {
  // ignore: unused_field
  final dynamic _character;

  StatTableModel([this._character]);

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

  /// Returns the stat abbreviation at [row] (e.g. "STR").
  String statName(int row) {
    if (row < 0 || row >= _rows.length) return '';
    return _rows[row].name;
  }

  /// Returns the base score at [row].
  int baseScore(int row) {
    if (row < 0 || row >= _rows.length) return 0;
    return _rows[row].base;
  }

  /// Returns the ability score modifier at [row].
  int modifier(int row) {
    if (row < 0 || row >= _rows.length) return 0;
    return _rows[row].modifier;
  }

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
