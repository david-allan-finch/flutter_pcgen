// Translation of pcgen.gui2.util.treetable.DefaultSortableTreeTableNode

import 'default_tree_table_node.dart';
import 'sortable_tree_table_node.dart';
import 'tree_table_node.dart';

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
