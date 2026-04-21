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
// Translation of pcgen.gui2.tabs.equip.EquipmentTableModel

import 'package:flutter/foundation.dart';

/// Table model for displaying available (unequipped) equipment items.
class EquipmentTableModel extends ChangeNotifier {
  static const List<String> columnNames = [
    'Name', 'Type', 'Location', 'Qty', 'Weight', 'Cost',
  ];

  final List<Map<String, dynamic>> _rows = [];

  int get rowCount => _rows.length;
  int get columnCount => columnNames.length;

  dynamic getValue(int row, int col) {
    if (row < 0 || row >= _rows.length) return null;
    final r = _rows[row];
    switch (col) {
      case 0: return r['name'];
      case 1: return r['type'];
      case 2: return r['location'];
      case 3: return r['qty'];
      case 4: return r['weight'];
      case 5: return r['cost'];
      default: return null;
    }
  }

  void setRows(List<Map<String, dynamic>> rows) {
    _rows
      ..clear()
      ..addAll(rows);
    notifyListeners();
  }

  void clear() {
    _rows.clear();
    notifyListeners();
  }
}
