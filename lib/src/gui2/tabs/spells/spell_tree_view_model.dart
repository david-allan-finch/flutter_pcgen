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
// Translation of pcgen.gui2.tabs.spells.SpellTreeViewModel

import 'package:flutter/foundation.dart';

/// Tree view model for spells, supporting grouping by class, level, school, etc.
class SpellTreeViewModel extends ChangeNotifier {
  static const String classView = 'Class';
  static const String levelView = 'Level';
  static const String schoolView = 'School';
  static const String descriptorView = 'Descriptor';
  static const String rangeView = 'Range';

  static const List<String> columnNames = [
    'Spell', 'School', 'Subschool', 'Descriptor',
    'Components', 'Cast Time', 'Range', 'Target/Area',
    'Duration', 'Save', 'SR', 'Source',
  ];

  String _currentView = classView;
  final List<Map<String, dynamic>> _spells = [];

  String get currentView => _currentView;

  void setView(String view) {
    _currentView = view;
    notifyListeners();
  }

  void setSpells(List<Map<String, dynamic>> spells) {
    _spells
      ..clear()
      ..addAll(spells);
    notifyListeners();
  }

  List<Map<String, dynamic>> get spells => List.unmodifiable(_spells);

  String groupKey(Map<String, dynamic> spell) {
    switch (_currentView) {
      case levelView:
        return 'Level ${spell['level'] ?? 0}';
      case schoolView:
        return spell['school'] as String? ?? 'Unknown';
      case descriptorView:
        return spell['descriptor'] as String? ?? 'None';
      case rangeView:
        return spell['range'] as String? ?? 'Unknown';
      default:
        return spell['class'] as String? ?? 'Unknown';
    }
  }

  Map<String, List<Map<String, dynamic>>> get grouped {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final spell in _spells) {
      final key = groupKey(spell);
      result.putIfAbsent(key, () => []).add(spell);
    }
    return result;
  }
}
