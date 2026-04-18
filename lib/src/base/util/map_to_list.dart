abstract interface class MapToList<K, V> {
  void initializeListFor(K key);
  void addToListFor(K key, V valueElement);
  void addAllToListFor(K key, Iterable<V> values);
  void addAllLists(MapToList<K, V> mtl);
  bool containsListFor(K key);
  bool containsInList(K key, V valueElement);
  int sizeOfListFor(K key);
  List<V>? getListFor(K key);
  List<V> getSafeListFor(K key);
  bool removeFromListFor(K key, V valueElement);
  List<V>? removeListFor(K key);
  bool isEmpty();
  int size();
  V getElementInList(K key, int index);
  void clear();
  Set<K> getKeySet();
}
