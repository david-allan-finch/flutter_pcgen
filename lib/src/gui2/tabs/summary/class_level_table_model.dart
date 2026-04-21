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
// Translation of pcgen.gui2.tabs.summary.ClassLevelTableModel

import 'package:flutter/foundation.dart';

/// Table model showing the character's class levels on the Summary tab.
class ClassLevelTableModel extends ChangeNotifier {
  // ignore: unused_field
  final dynamic _character;

  ClassLevelTableModel([this._character]);

  static const List<String> columnNames = [
    'Class', 'Level', 'HD', 'BAB', 'Fort', 'Ref', 'Will',
  ];

  final List<_ClassLevelRow> _rows = [];

  int get rowCount => _rows.length;
  int get columnCount => columnNames.length;

  dynamic getValue(int row, int col) {
    if (row < 0 || row >= _rows.length) return null;
    final r = _rows[row];
    switch (col) {
      case 0: return r.className;
      case 1: return r.level;
      case 2: return r.hitDie;
      case 3: return r.bab;
      case 4: return r.fortSave;
      case 5: return r.refSave;
      case 6: return r.willSave;
      default: return null;
    }
  }

  /// Returns the class name at [row].
  String className(int row) {
    if (row < 0 || row >= _rows.length) return '';
    return _rows[row].className;
  }

  /// Returns the class level at [row].
  int level(int row) {
    if (row < 0 || row >= _rows.length) return 0;
    return _rows[row].level;
  }

  /// Returns the hit points gained at [row] (stub — returns 0 until HP tracking added).
  int hp(int row) => 0;

  void setData(
      List<({String className, int level, String hitDie, String bab, String fortSave, String refSave, String willSave})> data) {
    _rows.clear();
    for (final d in data) {
      _rows.add(_ClassLevelRow(
        className: d.className,
        level: d.level,
        hitDie: d.hitDie,
        bab: d.bab,
        fortSave: d.fortSave,
        refSave: d.refSave,
        willSave: d.willSave,
      ));
    }
    notifyListeners();
  }

  void clear() {
    _rows.clear();
    notifyListeners();
  }
}

class _ClassLevelRow {
  final String className;
  final int level;
  final String hitDie;
  final String bab;
  final String fortSave;
  final String refSave;
  final String willSave;

  _ClassLevelRow({
    required this.className,
    required this.level,
    required this.hitDie,
    required this.bab,
    required this.fortSave,
    required this.refSave,
    required this.willSave,
  });
}
