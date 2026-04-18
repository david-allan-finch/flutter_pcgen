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
