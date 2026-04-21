import 'package:flutter_pcgen/src/base/util/triple_key_map.dart';

class TripleKeyMapToList<K1, K2, K3, V> {
  final TripleKeyMap<K1, K2, K3, List<V>> _map = TripleKeyMap();

  void addToListFor(K1 key1, K2 key2, K3 key3, V value) {
    var list = _map.get(key1, key2, key3);
    if (list == null) {
      list = <V>[];
      _map.put(key1, key2, key3, list);
    }
    list.add(value);
  }

  List<V>? getListFor(K1 key1, K2 key2, K3 key3) {
    final list = _map.get(key1, key2, key3);
    return list == null ? null : List<V>.from(list);
  }

  List<V> getSafeListFor(K1 key1, K2 key2, K3 key3) =>
      getListFor(key1, key2, key3) ?? [];

  bool containsListFor(K1 key1, K2 key2, K3 key3) =>
      _map.containsKey(key1, key2, key3);

  bool removeFromListFor(K1 key1, K2 key2, K3 key3, V value) {
    final list = _map.get(key1, key2, key3);
    if (list == null) return false;
    final removed = list.remove(value);
    if (removed && list.isEmpty) _map.remove(key1, key2, key3);
    return removed;
  }

  Set<K1> getKeySet() => _map.getKeySet();

  void clear() => _map.clear();
}
