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
// Translation of pcgen.gui2.util.treetable.DefaultSortableTreeTableNode

import 'package:flutter_pcgen/src/gui2/util/treetable/default_tree_table_node.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/sortable_tree_table_node.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_node.dart';

/// Default sortable tree table node that can sort its children.
class DefaultSortableTreeTableNode extends DefaultTreeTableNode
    implements SortableTreeTableNode {
  DefaultSortableTreeTableNode(super.values, {super.leaf});

  @override
  void sortChildren(Comparator<TreeTableNode> comparator) {
    // Sort children list
    final children = <TreeTableNode>[];
    for (int i = 0; i < getChildCount(); i++) {
      final child = getChildAt(i);
      if (child != null) children.add(child);
    }
    children.sort(comparator);
    // Rebuild by re-adding in sorted order
    for (final child in children) {
      if (child is SortableTreeTableNode) {
        child.sortChildren(comparator);
      }
    }
  }
}
