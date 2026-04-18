import 'list_facade.dart';

// Mutable, observable list for use in the facade layer.
class DefaultListFacade<E> implements ListFacade<E> {
  final List<E> _elementList;
  final List<void Function(ListChangeEvent<E>)> _listeners = [];

  DefaultListFacade() : _elementList = [];
  DefaultListFacade.from(Iterable<E> elements) : _elementList = List.of(elements);

  @override
  void addListListener(void Function(ListChangeEvent<E>) listener) {
    _listeners.add(listener);
  }

  @override
  void removeListListener(void Function(ListChangeEvent<E>) listener) {
    _listeners.remove(listener);
  }

  void _fire(ListChangeEvent<E> event) {
    for (final l in List.of(_listeners)) l(event);
  }

  @override
  E getElementAt(int index) => _elementList[index];

  @override
  int getSize() => _elementList.length;

  @override
  bool isEmpty() => _elementList.isEmpty;

  @override
  bool containsElement(E element) => _elementList.contains(element);

  int getIndexOfElement(E element) => _elementList.indexOf(element);

  void addElement(E element) => addElementAt(_elementList.length, element);

  void addElementAt(int index, E element) {
    _elementList.insert(index, element);
    _fire(ListChangeEvent(this, element, index, ListChangeType.added));
  }

  bool removeElement(E element) {
    final index = _elementList.indexOf(element);
    if (_elementList.remove(element)) {
      _fire(ListChangeEvent(this, element, index, ListChangeType.removed));
      return true;
    }
    return false;
  }

  void removeElementAt(int index) {
    final element = _elementList.removeAt(index);
    _fire(ListChangeEvent(this, element, index, ListChangeType.removed));
  }

  void modifyElement(E element) {
    final index = getIndexOfElement(element);
    if (index >= 0) {
      _fire(ListChangeEvent(this, element, index, ListChangeType.modified));
    }
  }

  void setContents(Iterable<E> elements) {
    _elementList.clear();
    _elementList.addAll(elements);
    _fire(ListChangeEvent(this, null, -1, ListChangeType.contentsChanged));
  }

  void clearContents() {
    if (_elementList.isNotEmpty) {
      _elementList.clear();
      _fire(ListChangeEvent(this, null, -1, ListChangeType.contentsChanged));
    }
  }

  void updateContents(List<E> newElements) {
    const maxUpdateSize = 20;
    if (isEmpty() || newElements.isEmpty || (getSize() - newElements.length).abs() > maxUpdateSize) {
      setContents(newElements);
      return;
    }
    // Remove elements not in new list
    int currPos = 0;
    for (int i = _elementList.length - 1; i >= 0; i--) {
      if (!newElements.contains(_elementList[i])) {
        final elem = _elementList.removeAt(i);
        _fire(ListChangeEvent(this, elem, i, ListChangeType.removed));
      }
    }
    // Insert elements from new list in order
    currPos = 0;
    for (final e in newElements) {
      if (_elementList.length <= currPos || _elementList[currPos] != e) {
        addElementAt(currPos, e);
      }
      currPos++;
    }
  }

  List<E> getContents() => List.of(_elementList);

  @override
  Iterator<E> get iterator => _elementList.iterator;

  @override
  String toString() => _elementList.toString();
}
