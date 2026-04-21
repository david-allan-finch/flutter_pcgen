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
// Translation of pcgen.gui2.tabs.ability.AbilityTreeViews

import '../../util/treeview/tree_view.dart';
import '../../util/treeview/tree_view_path.dart';

/// Predefined tree view strategies for abilities.
class AbilityTreeViews {
  AbilityTreeViews._();

  static const String nameViewName = 'Name';
  static const String typeViewName = 'Type';
  static const String preReqTreeViewName = 'Prerequisites';

  static TreeView<Map<String, dynamic>> nameView() => _NameAbilityTreeView();
  static TreeView<Map<String, dynamic>> typeView() => _TypeAbilityTreeView();
  static TreeView<Map<String, dynamic>> preReqView() => _PreReqAbilityTreeView();

  static List<TreeView<Map<String, dynamic>>> values() => [
    nameView(),
    typeView(),
    preReqView(),
  ];
}

class _NameAbilityTreeView implements TreeView<Map<String, dynamic>> {
  @override
  String getViewName() => AbilityTreeViews.nameViewName;

  @override
  TreeViewPath<Map<String, dynamic>> getPath(Map<String, dynamic> ability) {
    return TreeViewPath<Map<String, dynamic>>([ability]);
  }
}

class _TypeAbilityTreeView implements TreeView<Map<String, dynamic>> {
  @override
  String getViewName() => AbilityTreeViews.typeViewName;

  @override
  TreeViewPath<Map<String, dynamic>> getPath(Map<String, dynamic> ability) {
    final type = ability['type'] as String? ?? 'General';
    return TreeViewPath<Map<String, dynamic>>([
      <String, dynamic>{'name': type, '_isCategory': true},
      ability,
    ]);
  }
}

class _PreReqAbilityTreeView implements TreeView<Map<String, dynamic>> {
  @override
  String getViewName() => AbilityTreeViews.preReqTreeViewName;

  @override
  TreeViewPath<Map<String, dynamic>> getPath(Map<String, dynamic> ability) {
    return TreeViewPath<Map<String, dynamic>>([ability]);
  }
}
