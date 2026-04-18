import 'event/map_event.dart';

abstract interface class MapFacade<K, V> {
  void addMapListener(MapListener<K, V> listener);
  void removeMapListener(MapListener<K, V> listener);

  /// Returns the set of keys in this map.
  Set<K> getKeys();

  V? getValue(K key);

  int getSize();

  bool containsKey(K key);

  bool isEmpty();
}
