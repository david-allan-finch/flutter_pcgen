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
// Translation of pcgen.facade.util.SortedListFacade
import 'package:flutter_pcgen/src/base/logging/pcgen_logging.dart';

import 'abstract_list_facade.dart';
import 'list_facade.dart';

/// A [ListFacade] that presents elements from a delegate [ListFacade] in
/// sorted order according to a [Comparator].
class SortedListFacade<E> extends AbstractListFacade<E> {
  ListFacade<E>? _delegate;
  Comparator<E> _comparator;

  /// Maps sorted index → delegate index.
  List<int> _transform = [];

  void Function(ListChangeEvent<E>)? _delegateListener;

  SortedListFacade(this._comparator, [ListFacade<E>? list]) {
    if (list != null) setDelegate(list);
  }

  @override
  int getSize() => _delegate?.getSize() ?? 0;

  @override
  E getElementAt(int index) =>
      _delegate!.getElementAt(_transform[index]);

  void setDelegate(ListFacade<E>? list) {
    final old = _delegate;
    if (old != null && _delegateListener != null) {
      old.removeListListener(_delegateListener!);
    }
    _delegate = list;
    if (list != null) {
      _delegateListener = _onDelegateEvent;
      list.addListListener(_delegateListener!);
    } else {
      _delegateListener = null;
    }
    _rebuildTransform();
    fireElementsChanged(this);
  }

  void setComparator(Comparator<E> comparator) {
    _comparator = comparator;
    _rebuildTransform();
    fireElementsChanged(this);
  }

  void _rebuildTransform() {
    final d = _delegate;
    if (d == null) {
      _transform = [];
      return;
    }
    _transform = List.generate(d.getSize(), (i) => i);
    _transform.sort((a, b) => _comparator(d.getElementAt(a), d.getElementAt(b)));
  }

  bool _sanityCheck() {
    final d = _delegate;
    if (d == null || d.getSize() != _transform.length) {
      PcgenLogging.errorPrint(
          'SortedListFacade: size mismatch: '
          'transform=${_transform.length}, delegate=${d?.getSize()}');
      return false;
    }
    return true;
  }

  void _onDelegateEvent(ListChangeEvent<E> e) {
    final d = _delegate!;
    switch (e.type) {
      case ListChangeType.added:
        _transform.add(_transform.length);
        _sanityCheck();
        _transform.sort(
            (a, b) => _comparator(d.getElementAt(a), d.getElementAt(b)));
        final sortedIdx = _transform.indexOf(e.index);
        fireElementAdded(this, e.element as E, sortedIdx);
      case ListChangeType.removed:
        final sortedIdx = _transform.indexOf(e.index);
        _transform.remove(_transform.length - 1);
        _sanityCheck();
        _transform.sort(
            (a, b) => _comparator(d.getElementAt(a), d.getElementAt(b)));
        fireElementRemoved(this, e.element as E, sortedIdx);
      case ListChangeType.contentsChanged:
        _rebuildTransform();
        fireElementsChanged(this);
      case ListChangeType.modified:
        _sanityCheck();
        final sortedIdx = _transform.indexOf(e.index);
        fireElementModified(this, e.element as E, sortedIdx);
    }
  }
}
