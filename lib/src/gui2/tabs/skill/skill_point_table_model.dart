//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.skill.SkillPointTableModel

import 'package:flutter/foundation.dart';

/// Table model showing skill point pools per class level.
class SkillPointTableModel extends ChangeNotifier {
  static const List<String> columnNames = [
    'Class', 'Level', 'Points/Level', 'Points Remaining',
  ];

  final List<_SkillPointRow> _rows = [];

  int get rowCount => _rows.length;
  int get columnCount => columnNames.length;

  dynamic getValue(int row, int col) {
    if (row < 0 || row >= _rows.length) return null;
    final r = _rows[row];
    switch (col) {
      case 0: return r.className;
      case 1: return r.level;
      case 2: return r.pointsPerLevel;
      case 3: return r.pointsRemaining;
      default: return null;
    }
  }

  void setData(List<({String className, int level, int pointsPerLevel, int pointsRemaining})> data) {
    _rows.clear();
    for (final d in data) {
      _rows.add(_SkillPointRow(
        className: d.className,
        level: d.level,
        pointsPerLevel: d.pointsPerLevel,
        pointsRemaining: d.pointsRemaining,
      ));
    }
    notifyListeners();
  }

  void clear() {
    _rows.clear();
    notifyListeners();
  }
}

class _SkillPointRow {
  final String className;
  final int level;
  final int pointsPerLevel;
  final int pointsRemaining;

  _SkillPointRow({
    required this.className,
    required this.level,
    required this.pointsPerLevel,
    required this.pointsRemaining,
  });
}
