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
// Translation of pcgen.gui2.util.treeview.TreeViewTableModel

import 'package:flutter/foundation.dart';
import 'tree_view.dart';
import 'tree_view_path.dart';
import 'data_view.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_listener.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_event.dart';

/// A ChangeNotifier model that combines a TreeView (hierarchy strategy)
/// with a DataView (column data) over a ListFacade.
class TreeViewTableModel<T> extends ChangeNotifier implements ListListener<T> {
  ListFacade<T>? _listFacade;
  TreeView<T>? _currentView;
  final DataView<T> _dataView;
  final List<_TreeNode<T>> _roots = [];
  final Map<T, _TreeNode<T>> _nodeMap = {};

  TreeViewTableModel(this._dataView);

  void setTreeView(TreeView<T> view) {
    _currentView = view;
    _rebuild();
    notifyListeners();
  }

  void setListFacade(ListFacade<T> list) {
    _listFacade?.removeListListener(this);
    _listFacade = list;
    _listFacade?.addListListener(this);
    _rebuild();
    notifyListeners();
  }

  void _rebuild() {
    _roots.clear();
    _nodeMap.clear();
    final list = _listFacade;
    final view = _currentView;
    if (list == null || view == null) return;
    for (int i = 0; i < list.getSize(); i++) {
      final element = list.getElementAt(i);
      _insertElement(element, view.getPath(element));
    }
  }

  void _insertElement(T element, List<dynamic> path) {
    // Build path nodes
    _TreeNode<T>? parent;
    List<_TreeNode<T>> children = _roots;
    for (int i = 0; i < path.length - 1; i++) {
      final key = path[i];
      _TreeNode<T>? found;
      for (final n in children) {
        if (n.key == key) { found = n; break; }
      }
      if (found == null) {
        found = _TreeNode<T>(key, null);
        children.add(found);
      }
      parent = found;
      children = found.children;
    }
    final leaf = _TreeNode<T>(path.last, element);
    children.add(leaf);
    _nodeMap[element] = leaf;
  }

  List<_TreeNode<T>> get roots => _roots;
  DataView<T> get dataView => _dataView;

  @override
  void elementAdded(ListEvent<T> e) { _rebuild(); notifyListeners(); }
  @override
  void elementRemoved(ListEvent<T> e) { _rebuild(); notifyListeners(); }
  @override
  void elementsChanged(ListEvent<T> e) { _rebuild(); notifyListeners(); }
  @override
  void elementModified(ListEvent<T> e) {
    final el = e.element;
    if (el != null) _nodeMap[el]?.markDirty();
    notifyListeners();
  }

  @override
  void dispose() {
    _listFacade?.removeListListener(this);
    super.dispose();
  }
}

class _TreeNode<T> {
  final dynamic key;
  final T? element;
  final List<_TreeNode<T>> children = [];
  bool _dirty = false;

  _TreeNode(this.key, this.element);

  bool get isLeaf => element != null;
  void markDirty() => _dirty = true;
}
