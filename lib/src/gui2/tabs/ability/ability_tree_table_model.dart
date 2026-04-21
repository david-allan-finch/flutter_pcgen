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
// Translation of pcgen.gui2.tabs.ability.AbilityTreeTableModel

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/abstract_tree_table_model.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/default_sortable_tree_table_node.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/sortable_tree_table_node.dart';

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
