// Translation of pcgen.gui2.util.treetable.SortableTreeTableModel

import 'abstract_tree_table_model.dart';
import 'sortable_tree_table_node.dart';
import 'tree_table_node.dart';

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
