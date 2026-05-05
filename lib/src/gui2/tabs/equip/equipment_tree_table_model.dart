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
// Translation of pcgen.gui2.tabs.equip.EquipmentTreeTableModel

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/abstract_tree_table_model.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/default_sortable_tree_table_node.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/sortable_tree_table_node.dart';

/// Tree table model for equipped items, organized by location/slot.
class EquipmentTreeTableModel extends AbstractTreeTableModel with ChangeNotifier {
  static const List<String> columnNames = [
    'Name', 'Type', 'Location', 'Qty', 'Weight', 'Cost',
  ];

  EquipmentTreeTableModel() : super(DefaultSortableTreeTableNode([]));

  DefaultSortableTreeTableNode _root = DefaultSortableTreeTableNode([]);

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
      return node.getValueAt(column);
    }
    return null;
  }

  @override
  bool isLeaf(dynamic node) {
    if (node is DefaultSortableTreeTableNode) return node.getChildCount() == 0;
    return true;
  }

  /// Rebuild tree from a map of location → list of item rows.
  void setEquipment(Map<String, List<List<dynamic>>> byLocation) {
    _root = DefaultSortableTreeTableNode([]);
    for (final entry in byLocation.entries) {
      final locNode = DefaultSortableTreeTableNode(
          [entry.key, '', '', '', '', '']);
      for (final row in entry.value) {
        locNode.add(DefaultSortableTreeTableNode(List<dynamic>.from(row)));
      }
      _root.add(locNode);
    }
    notifyListeners();
  }
}
