// A map where the key is derived from the value itself.
class KeyMap<K, V> {
  final Map<K, V> _map = {};
  final K Function(V) _keyOf;

  KeyMap(this._keyOf);

  V? put(V value) {
    final key = _keyOf(value);
    final old = _map[key];
    _map[key] = value;
    return old;
  }

  V? get(K key) => _map[key];

  bool containsKey(K key) => _map.containsKey(key);

  V? remove(K key) => _map.remove(key);

  Set<K> keySet() => Set<K>.from(_map.keys);

  Iterable<V> get values => _map.values;

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;

  int get size => _map.length;
}
