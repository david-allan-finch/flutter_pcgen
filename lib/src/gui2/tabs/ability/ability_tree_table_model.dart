// Translation of pcgen.gui2.tabs.ability.AbilityTreeTableModel

import 'package:flutter/foundation.dart';
import '../../util/treetable/abstract_tree_table_model.dart';
import '../../util/treetable/default_sortable_tree_table_node.dart';
import '../../util/treetable/sortable_tree_table_node.dart';

/// Tree table model for abilities, grouped by category.
class AbilityTreeTableModel extends AbstractTreeTableModel with ChangeNotifier {
  static const List<String> columnNames = [
    'Name', 'Type', 'Mult', 'Stack', 'Description',
  ];

  final DefaultSortableTreeTableNode _root;

  AbilityTreeTableModel() : _root = DefaultSortableTreeTableNode('root', []);

  @override
  SortableTreeTableNode get root => _root;

  @override
  int get columnCount => columnNames.length;

  @override
  String getColumnName(int column) => columnNames[column];

  @override
  dynamic getValueAt(dynamic node, int column) {
    if (node is DefaultSortableTreeTableNode) {
      final data = node.data;
      if (data is List && column < data.length) return data[column];
    }
    return null;
  }

  @override
  bool isLeaf(dynamic node) {
    if (node is DefaultSortableTreeTableNode) return node.childCount == 0;
    return true;
  }

  void setData(Map<String, List<List<dynamic>>> categorized) {
    _root.removeAllChildren();
    for (final entry in categorized.entries) {
      final catNode = DefaultSortableTreeTableNode(entry.key, [entry.key, '', '', '', '']);
      for (final row in entry.value) {
        catNode.addChild(DefaultSortableTreeTableNode(row[0] as String, row));
      }
      _root.addChild(catNode);
    }
    notifyListeners();
  }
}
