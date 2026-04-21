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
