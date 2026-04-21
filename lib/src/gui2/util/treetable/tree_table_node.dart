// Translation of pcgen.gui2.util.treetable.TreeTableNode

/// Interface for nodes in a tree table.
abstract class TreeTableNode {
  dynamic getValueAt(int column);
  int getColumnCount();
  bool isLeaf();
  int getChildCount();
  TreeTableNode? getChildAt(int index);
  TreeTableNode? getParent();
}
