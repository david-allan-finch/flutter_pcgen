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
