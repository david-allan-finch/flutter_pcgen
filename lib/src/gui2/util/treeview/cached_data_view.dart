// Translation of pcgen.gui2.util.treeview.CachedDataView

import 'data_view.dart';

/// A DataView wrapper that caches data values to avoid redundant lookups.
class CachedDataView<T> implements DataView<T> {
  final DataView<T> _delegate;
  final Map<T, List<dynamic?>> _cache = {};

  CachedDataView(this._delegate);

  @override
  List<dynamic> getColumns() => _delegate.getColumns();

  @override
  dynamic getData(T element, int column) {
    _cache.putIfAbsent(element, () => List.filled(getColumns().length, null));
    final cached = _cache[element]![column];
    if (cached != null) return cached;
    final value = _delegate.getData(element, column);
    _cache[element]![column] = value;
    return value;
  }

  @override
  bool isLeaf(T element) => _delegate.isLeaf(element);

  void invalidate(T element) => _cache.remove(element);

  void invalidateAll() => _cache.clear();
}
