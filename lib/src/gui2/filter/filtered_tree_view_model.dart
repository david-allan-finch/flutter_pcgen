// Translation of pcgen.gui2.filter.FilteredTreeViewModel

import 'package:flutter/foundation.dart';
import 'filter.dart';
import '../util/treeview/tree_view.dart';
import '../util/treeview/tree_view_model.dart';
import '../facade/util/list_facade.dart';
import '../facade/util/event/list_listener.dart';
import '../facade/util/event/list_event.dart';

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
