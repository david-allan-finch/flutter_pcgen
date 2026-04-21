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
// Translation of pcgen.facade.util.AbstractListFacade
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';

/// Base class for [ListFacade] implementations providing listener management
/// and fire helper methods.
abstract class AbstractListFacade<E> implements ListFacade<E> {
  final List<void Function(ListChangeEvent<E>)> _listeners = [];

  @override
  void addListListener(void Function(ListChangeEvent<E>) listener) {
    _listeners.add(listener);
  }

  @override
  void removeListListener(void Function(ListChangeEvent<E>) listener) {
    _listeners.remove(listener);
  }

  @override
  bool isEmpty() => getSize() == 0;

  @override
  bool containsElement(E element) {
    for (final e in this) {
      if (e == element) return true;
    }
    return false;
  }

  @override
  Iterator<E> get iterator => _IndexIterator(this);

  void _fire(ListChangeEvent<E> event) {
    for (final l in List.of(_listeners)) l(event);
  }

  void fireElementAdded(Object source, E element, int index) =>
      _fire(ListChangeEvent(source, element, index, ListChangeType.added));

  void fireElementRemoved(Object source, E element, int index) =>
      _fire(ListChangeEvent(source, element, index, ListChangeType.removed));

  void fireElementsChanged(Object source) =>
      _fire(ListChangeEvent(source, null, -1, ListChangeType.contentsChanged));

  void fireElementModified(Object source, E element, int index) =>
      _fire(ListChangeEvent(source, element, index, ListChangeType.modified));
}

class _IndexIterator<E> implements Iterator<E> {
  final AbstractListFacade<E> _facade;
  int _index = -1;

  _IndexIterator(this._facade);

  @override
  E get current => _facade.getElementAt(_index);

  @override
  bool moveNext() {
    _index++;
    return _index < _facade.getSize();
  }
}
