abstract interface class Changes<T> {
  bool hasAddedItems();

  bool hasRemovedItems();

  bool includesGlobalClear();

  List<T>? getAdded();

  List<T>? getRemoved();

  bool isEmpty();
}
