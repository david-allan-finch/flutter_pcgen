//
// Copyright 2016 Connor Petty <cpmeister@users.sourceforge.net>
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
