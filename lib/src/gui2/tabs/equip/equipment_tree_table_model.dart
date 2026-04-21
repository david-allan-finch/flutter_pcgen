// Translation of pcgen.gui2.tabs.equip.EquipmentTreeTableModel

import 'package:flutter/foundation.dart';
import '../../util/treetable/abstract_tree_table_model.dart';
import '../../util/treetable/default_sortable_tree_table_node.dart';
import '../../util/treetable/sortable_tree_table_node.dart';

/// Tree table model for equipped items, organized by location/slot.
class EquipmentTreeTableModel extends AbstractTreeTableModel with ChangeNotifier {
  static const List<String> columnNames = [
    'Name', 'Type', 'Location', 'Qty', 'Weight', 'Cost',
  ];

  final DefaultSortableTreeTableNode _root;

  EquipmentTreeTableModel()
      : _root = DefaultSortableTreeTableNode('root', []);

  @override
  SortableTreeTableNode get root => _root;

  @override
  int get columnCount => columnNames.length;

  @override
  String getColumnName(int column) =>
      column < columnNames.length ? columnNames[column] : '';

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

  /// Rebuild tree from a map of location → list of item rows.
  void setEquipment(Map<String, List<List<dynamic>>> byLocation) {
    _root.removeAllChildren();
    for (final entry in byLocation.entries) {
      final locNode = DefaultSortableTreeTableNode(
          entry.key, [entry.key, '', '', '', '', '']);
      for (final row in entry.value) {
        locNode.addChild(
            DefaultSortableTreeTableNode(row[0] as String? ?? '', row));
      }
      _root.addChild(locNode);
    }
    notifyListeners();
  }
}
