// Observable list abstraction for the facade layer.
abstract interface class ListFacade<E> implements Iterable<E> {
  void addListListener(void Function(ListChangeEvent<E>) listener);
  void removeListListener(void Function(ListChangeEvent<E>) listener);
  E getElementAt(int index);
  int getSize();
  bool isEmpty();
  bool containsElement(E element);
}

enum ListChangeType { added, removed, modified, contentsChanged }

class ListChangeEvent<E> {
  final Object source;
  final E? element;
  final int index;
  final ListChangeType type;
  const ListChangeEvent(this.source, this.element, this.index, this.type);
}
