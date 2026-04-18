import 'double_key_map.dart';

class TripleKeyMap<K1, K2, K3, V> {
  final DoubleKeyMap<K1, K2, Map<K3, V>> _map = DoubleKeyMap();

  V? put(K1 key1, K2 key2, K3 key3, V value) {
    var inner = _map.get(key1, key2);
    if (inner == null) {
      inner = <K3, V>{};
      _map.put(key1, key2, inner);
    }
    final old = inner[key3];
    inner[key3] = value;
    return old;
  }

  V? get(K1 key1, K2 key2, K3 key3) => _map.get(key1, key2)?[key3];

  bool containsKey(K1 key1, K2 key2, K3 key3) =>
      _map.get(key1, key2)?.containsKey(key3) ?? false;

  V? remove(K1 key1, K2 key2, K3 key3) {
    final inner = _map.get(key1, key2);
    if (inner == null) return null;
    final removed = inner.remove(key3);
    if (inner.isEmpty) _map.remove(key1, key2);
    return removed;
  }

  Set<K1> getKeySet() => _map.getKeySet();

  Set<K2> getSecondaryKeySet(K1 key1) => _map.getSecondaryKeySet(key1);

  Set<K3> getTertiaryKeySet(K1 key1, K2 key2) {
    final inner = _map.get(key1, key2);
    return inner == null ? <K3>{} : Set<K3>.from(inner.keys);
  }

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;
}
