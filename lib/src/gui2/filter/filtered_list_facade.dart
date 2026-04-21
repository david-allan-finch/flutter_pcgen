// Translation of pcgen.gui2.filter.FilteredListFacade

import 'package:flutter/foundation.dart';
import 'filter.dart';
import '../facade/util/list_facade.dart';
import '../facade/util/event/list_listener.dart';
import '../facade/util/event/list_event.dart';

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
