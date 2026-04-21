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
// Translation of pcgen.gui2.util.treetable.DefaultTreeTableNode

import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_node.dart';

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
