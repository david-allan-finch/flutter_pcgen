//
// Copyright 2008 (C) Connor Petty <mistercpp2000@gmail.com>
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
// Translation of pcgen.gui2.util.treetable.SortableTreeTableModel

import 'package:flutter_pcgen/src/gui2/util/treetable/abstract_tree_table_model.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/sortable_tree_table_node.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_node.dart';

/// A tree table model that can sort its rows.
abstract class SortableTreeTableModel extends AbstractTreeTableModel {
  int? _sortColumn;
  bool _sortAscending = true;

  SortableTreeTableModel(super.root);

  void sort(int column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    _sortNode(root);
    fireTreeStructureChanged(root);
  }

  void _sortNode(TreeTableNode node) {
    if (node is SortableTreeTableNode && _sortColumn != null) {
      node.sortChildren((a, b) {
        final va = a.getValueAt(_sortColumn!);
        final vb = b.getValueAt(_sortColumn!);
        int cmp = _compare(va, vb);
        return _sortAscending ? cmp : -cmp;
      });
    }
    for (int i = 0; i < node.getChildCount(); i++) {
      final child = node.getChildAt(i);
      if (child != null) _sortNode(child);
    }
  }

  int _compare(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is Comparable) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }
}
