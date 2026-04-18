import 'double_key_map.dart';
import 'hash_map_to_list.dart';
import 'map_to_list.dart';

class DoubleKeyMapToList<K1, K2, V> {
  final DoubleKeyMap<K1, K2, List<V>> _map = DoubleKeyMap();

  void addToListFor(K1 key1, K2 key2, V value) {
    var list = _map.get(key1, key2);
    if (list == null) {
      list = <V>[];
      _map.put(key1, key2, list);
    }
    list.add(value);
  }

  List<V>? getListFor(K1 key1, K2 key2) {
    final list = _map.get(key1, key2);
    return list == null ? null : List<V>.from(list);
  }

  List<V> getSafeListFor(K1 key1, K2 key2) => getListFor(key1, key2) ?? [];

  bool containsListFor(K1 key1, K2 key2) => _map.containsKey(key1, key2);

  bool removeFromListFor(K1 key1, K2 key2, V value) {
    final list = _map.get(key1, key2);
    if (list == null) return false;
    final removed = list.remove(value);
    if (removed && list.isEmpty) _map.remove(key1, key2);
    return removed;
  }

  List<V>? removeListFor(K1 key1, K2 key2) {
    return _map.remove(key1, key2);
  }

  Set<K1> getKeySet() => _map.getKeySet();

  Set<K2> getSecondaryKeySet(K1 key1) => _map.getSecondaryKeySet(key1);

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;
}
