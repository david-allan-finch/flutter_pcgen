// Translation of pcgen.gui2.util.treetable.DefaultTreeTableNode

import 'tree_table_node.dart';

/// Default mutable implementation of TreeTableNode.
class DefaultTreeTableNode implements TreeTableNode {
  final List<dynamic> _values;
  final List<TreeTableNode> _children = [];
  TreeTableNode? _parent;
  bool _leaf;

  DefaultTreeTableNode(List<dynamic> values, {bool leaf = false})
      : _values = List.of(values),
        _leaf = leaf;

  void add(TreeTableNode child) {
    _children.add(child);
    if (child is DefaultTreeTableNode) {
      child._parent = this;
    }
    _leaf = false;
  }

  void remove(TreeTableNode child) {
    _children.remove(child);
  }

  @override
  dynamic getValueAt(int column) {
    if (column < 0 || column >= _values.length) return null;
    return _values[column];
  }

  void setValueAt(dynamic value, int column) {
    if (column >= 0 && column < _values.length) _values[column] = value;
  }

  @override
  int getColumnCount() => _values.length;

  @override
  bool isLeaf() => _leaf || _children.isEmpty;

  @override
  int getChildCount() => _children.length;

  @override
  TreeTableNode? getChildAt(int index) {
    if (index < 0 || index >= _children.length) return null;
    return _children[index];
  }

  @override
  TreeTableNode? getParent() => _parent;
}
