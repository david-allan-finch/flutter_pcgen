//
// Copyright 2018 (C) Thomas Parker
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.facade.DelegatingSingleton

import '../../facade/util/abstract_list_facade.dart';
import '../../facade/util/reference_facade.dart';

/// Wraps a ReferenceFacade to allow that singleton object reference to instead
/// appear as a ListFacade.
///
/// This is useful because certain items which are recognized by most game modes
/// as a singleton (Race) are nonetheless stored and displayed within list
/// structures in PCGen. This centralizes the decoration of the singleton into
/// a list.
class DelegatingSingleton<E> extends AbstractListFacade<E> {
  final ReferenceFacade<E> _underlying;

  DelegatingSingleton(ReferenceFacade<E> underlying)
      : _underlying = underlying {
    underlying.addReferenceListener(_onReferenceChanged);
  }

  @override
  E getElementAt(int index) {
    if (index != 0) {
      throw RangeError.index(index, this, 'index', null, getSize());
    }
    E? item = _underlying.get();
    if (item == null) {
      throw RangeError.index(index, this, 'index', null, 0);
    }
    return item;
  }

  @override
  int getSize() => (_underlying.get() == null) ? 0 : 1;

  @override
  bool containsElement(E element) {
    E? item = _underlying.get();
    return item != null && item == element;
  }

  void _onReferenceChanged(dynamic e) {
    E? oldRef = e.oldReference as E?;
    E? newRef = e.newReference as E?;
    if (oldRef != null) {
      fireElementRemoved(this, oldRef, 0);
    }
    if (newRef != null) {
      fireElementAdded(this, newRef, 0);
    }
  }
}
