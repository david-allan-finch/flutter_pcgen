// Translation of pcgen.gui2.util.treetable.SortableTreeTableNode

import 'tree_table_node.dart';

/// TreeTableNode that supports sorting of its children.
abstract class SortableTreeTableNode implements TreeTableNode {
  void sortChildren(Comparator<TreeTableNode> comparator);
}
