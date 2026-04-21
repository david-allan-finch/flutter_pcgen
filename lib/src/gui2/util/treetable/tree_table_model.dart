// Translation of pcgen.gui2.util.treetable.TreeTableModel

import 'tree_table_node.dart';

/// Model for a tree-table (combined tree and table view).
abstract class TreeTableModel {
  TreeTableNode get root;
  int get columnCount;
  String getColumnName(int column);
  Type getColumnClass(int column);
  bool isCellEditable(TreeTableNode node, int column);
  dynamic getValueAt(TreeTableNode node, int column);
  void setValueAt(dynamic value, TreeTableNode node, int column);
  void addTreeModelListener(dynamic listener);
  void removeTreeModelListener(dynamic listener);
}
