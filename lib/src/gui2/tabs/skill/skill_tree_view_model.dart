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
// Translation of pcgen.gui2.tabs.skill.SkillTreeViewModel

import 'package:flutter/foundation.dart';
import '../../util/treeview/tree_view.dart';
import '../../util/treeview/tree_view_path.dart';

/// Tree view model for skills, supporting grouping by name, type, or cost.
class SkillTreeViewModel extends ChangeNotifier {
  static const String nameView = 'Name';
  static const String typeView = 'Type';
  static const String costView = 'Cost';

  static const List<String> columnNames = [
    'Skill', 'Total', 'Mod', 'Rank', 'Class', 'Cross-class Cost', 'Source',
  ];

  String _currentView = nameView;
  final List<Map<String, dynamic>> _skills = [];

  String get currentView => _currentView;

  void setView(String view) {
    _currentView = view;
    notifyListeners();
  }

  void setSkills(List<Map<String, dynamic>> skills) {
    _skills
      ..clear()
      ..addAll(skills);
    notifyListeners();
  }

  /// Returns flat list of visible rows for the current view.
  List<Map<String, dynamic>> get rows => List.unmodifiable(_skills);

  /// Returns grouping key for the current view.
  String groupKey(Map<String, dynamic> skill) {
    switch (_currentView) {
      case typeView:
        return skill['type'] as String? ?? 'General';
      case costView:
        final isClass = skill['classSkill'] as bool? ?? false;
        return isClass ? 'Class Skills' : 'Cross-Class Skills';
      default:
        return skill['name'] as String? ?? '';
    }
  }

  Map<String, List<Map<String, dynamic>>> get grouped {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final skill in _skills) {
      final key = groupKey(skill);
      result.putIfAbsent(key, () => []).add(skill);
    }
    return result;
  }
}
