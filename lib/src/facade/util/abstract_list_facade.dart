import 'list_facade.dart';

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
