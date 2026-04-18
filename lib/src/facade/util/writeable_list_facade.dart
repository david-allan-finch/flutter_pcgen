import 'list_facade.dart';

// Mutable version of ListFacade — supports add and remove.
abstract interface class WriteableListFacade<E> implements ListFacade<E> {
  void addElement(E element);
  void addElementAt(int index, E element);
  bool removeElement(E element);
  void removeElementAt(int index);
}
