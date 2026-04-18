// A map to list that uses identity equality for list element comparison.
class HashMapToInstanceList<K, V> {
  final Map<K, List<V>> _map = {};

  void addToListFor(K key, V value) {
    _map.putIfAbsent(key, () => []).add(value);
  }

  bool containsListFor(K key) => _map.containsKey(key);

  bool containsInList(K key, V value) {
    final list = _map[key];
    if (list == null) return false;
    return list.any((e) => identical(e, value));
  }

  List<V>? getListFor(K key) {
    final list = _map[key];
    return list == null ? null : List<V>.from(list);
  }

  bool removeFromListFor(K key, V value) {
    final list = _map[key];
    if (list == null) return false;
    for (int i = 0; i < list.length; i++) {
      if (identical(list[i], value)) {
        list.removeAt(i);
        if (list.isEmpty) _map.remove(key);
        return true;
      }
    }
    return false;
  }

  Set<K> getKeySet() => Set<K>.from(_map.keys);

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;
}
