//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.filter.FilteredTreeViewModel

import 'package:flutter/foundation.dart';
import 'filter.dart';
import 'package:flutter_pcgen/src/gui2/util/treeview/tree_view.dart';
import 'package:flutter_pcgen/src/gui2/util/treeview/tree_view_model.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_listener.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_event.dart';

/// A TreeViewModel that wraps another and applies a filter.
class FilteredTreeViewModel<T> extends ChangeNotifier
    implements TreeViewModel<T>, ListListener<T> {
  final TreeViewModel<T> _delegate;
  Filter<T>? _filter;
  dynamic _filterContext;
  ListFacade<T>? _filteredSource;

  FilteredTreeViewModel(this._delegate);

  void setFilter(Filter<T>? filter, [dynamic context]) {
    _filter = filter;
    _filterContext = context;
    notifyListeners();
  }

  bool _accepts(T element) =>
      _filter == null || _filter!.accept(element, _filterContext);

  @override
  ListFacade<T> getDataModel() => _delegate.getDataModel();

  @override
  List<TreeView<T>> getTreeViews() => _delegate.getTreeViews();

  @override
  List<dynamic> getColumns() => _delegate.getColumns();

  @override
  dynamic getData(T element, int column) => _delegate.getData(element, column);

  @override
  TreeView<T> getDefaultTreeView() => _delegate.getDefaultTreeView();

  @override
  void elementAdded(ListEvent<T> e) => notifyListeners();
  @override
  void elementRemoved(ListEvent<T> e) => notifyListeners();
  @override
  void elementsChanged(ListEvent<T> e) => notifyListeners();
  @override
  void elementModified(ListEvent<T> e) => notifyListeners();
}
