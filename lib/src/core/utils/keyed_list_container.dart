// Copyright (c) Tom Parker, 2005.
//
// Translation of pcgen.core.utils.KeyedListContainer

/// Interface for objects that safely expose a ListKey → List<T> map.
abstract interface class KeyedListContainer {
  bool containsListFor(dynamic key);
  List<T> getListFor<T>(dynamic key);
  int getSizeOfListFor(dynamic key);
  bool containsInList<T>(dynamic key, T value);
  T getElementInList<T>(dynamic key, int i);
  List<T> getSafeListFor<T>(dynamic key);
  int getSafeSizeOfListFor(dynamic key);
}
