//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.filter.FilteredListFacade

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_listener.dart';
import 'package:flutter_pcgen/src/facade/util/event/list_event.dart';

/// A ListFacade that filters elements from a source ListFacade.
class FilteredListFacade<E> extends ChangeNotifier
    implements ListFacade<E>, ListListener<E> {
  ListFacade<E>? _source;
  Filter<E>? _filter;
  dynamic _context;
  final List<E> _filtered = [];

  FilteredListFacade([ListFacade<E>? source]) {
    if (source != null) setListFacade(source);
  }

  void setListFacade(ListFacade<E> source) {
    _source?.removeListListener(this);
    _source = source;
    _source?.addListListener(this);
    _rebuild();
  }

  void setFilter(Filter<E>? filter, [dynamic context]) {
    _filter = filter;
    _context = context;
    _rebuild();
    notifyListeners();
  }

  void _rebuild() {
    _filtered.clear();
    final src = _source;
    if (src == null) return;
    for (int i = 0; i < src.getSize(); i++) {
      final el = src.getElementAt(i);
      if (_filter == null || _filter!.accept(el, _context)) {
        _filtered.add(el);
      }
    }
  }

  @override
  int getSize() => _filtered.length;

  @override
  E getElementAt(int index) => _filtered[index];

  @override
  void addListListener(ListListener<E> listener) {}

  @override
  void removeListListener(ListListener<E> listener) {}

  bool containsElement(E element) => _filtered.contains(element);

  @override
  void elementAdded(ListEvent<E> e) { _rebuild(); notifyListeners(); }
  @override
  void elementRemoved(ListEvent<E> e) { _rebuild(); notifyListeners(); }
  @override
  void elementsChanged(ListEvent<E> e) { _rebuild(); notifyListeners(); }
  @override
  void elementModified(ListEvent<E> e) { _rebuild(); notifyListeners(); }

  @override
  void dispose() {
    _source?.removeListListener(this);
    super.dispose();
  }
}
