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
// Translation of pcgen.facade.util.DelegatingListFacade
import 'abstract_list_facade.dart';
import 'list_facade.dart';

/// A [ListFacade] that delegates to another [ListFacade] and re-fires its
/// events. Useful for swapping out the underlying list at runtime.
class DelegatingListFacade<E> extends AbstractListFacade<E> {
  ListFacade<E>? _delegate;
  void Function(ListChangeEvent<E>)? _delegateListener;

  DelegatingListFacade([ListFacade<E>? delegate]) {
    if (delegate != null) setDelegate(delegate);
  }

  @override
  E getElementAt(int index) {
    final d = _delegate;
    if (d == null) throw StateError('No delegate set');
    return d.getElementAt(index);
  }

  @override
  int getSize() => _delegate?.getSize() ?? 0;

  void setDelegate(ListFacade<E>? list) {
    final old = _delegate;
    if (old == list) return;
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
    fireElementsChanged(this);
  }

  void _onDelegateEvent(ListChangeEvent<E> e) {
    switch (e.type) {
      case ListChangeType.added:
        fireElementAdded(this, e.element as E, e.index);
      case ListChangeType.removed:
        fireElementRemoved(this, e.element as E, e.index);
      case ListChangeType.modified:
        fireElementModified(this, e.element as E, e.index);
      case ListChangeType.contentsChanged:
        fireElementsChanged(this);
    }
  }
}
