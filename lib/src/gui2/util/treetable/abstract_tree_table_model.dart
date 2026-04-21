//
// @(#)AbstractTreeTableModel.java    1.2 98/10/27
//
// Copyright 1997, 1998 by Sun Microsystems, Inc.,
// 901 San Antonio Road, Palo Alto, California, 94303, U.S.A.
// All rights reserved.
//
// This software is the confidential and proprietary information
// of Sun Microsystems, Inc. ("Confidential Information").  You
// shall not disclose such Confidential Information and shall use
// it only in accordance with the terms of the license agreement
// you entered into with Sun.
//
// Translation of pcgen.gui2.util.treetable.AbstractTreeTableModel

import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_model.dart';
import 'package:flutter_pcgen/src/gui2/util/treetable/tree_table_node.dart';

/// Abstract base for tree table models. Provides default implementations
/// of listener management and cell editability.
abstract class AbstractTreeTableModel implements TreeTableModel {
  final TreeTableNode _root;
  final List<dynamic> _listeners = [];

  AbstractTreeTableModel(this._root);

  @override
  TreeTableNode get root => _root;

  @override
  bool isCellEditable(TreeTableNode node, int column) => false;

  @override
  void setValueAt(dynamic value, TreeTableNode node, int column) {}

  @override
  void addTreeModelListener(dynamic listener) => _listeners.add(listener);

  @override
  void removeTreeModelListener(dynamic listener) => _listeners.remove(listener);

  @override
  Type getColumnClass(int column) => Object;

  void fireTreeStructureChanged(TreeTableNode node) {
    for (final l in _listeners) {
      try {
        l.treeStructureChanged(null);
      } catch (_) {}
    }
  }

  void fireTreeNodesInserted(TreeTableNode parent, List<int> indices) {
    for (final l in _listeners) {
      try {
        l.treeNodesInserted(null);
      } catch (_) {}
    }
  }

  void fireTreeNodesRemoved(TreeTableNode parent, List<int> indices) {
    for (final l in _listeners) {
      try {
        l.treeNodesRemoved(null);
      } catch (_) {}
    }
  }
}
