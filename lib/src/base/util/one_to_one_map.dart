class OneToOneMap<K, V> {
  final Map<K, V> _forward = {};
  final Map<V, K> _reverse = {};

  V? put(K key, V value) {
    final oldValue = _forward.remove(key);
    if (oldValue != null) _reverse.remove(oldValue);
    final oldKey = _reverse.remove(value);
    if (oldKey != null) _forward.remove(oldKey);
    _forward[key] = value;
    _reverse[value] = key;
    return oldValue;
  }

  V? get(K key) => _forward[key];

  K? getKeyFor(V value) => _reverse[value];

  bool containsKey(K key) => _forward.containsKey(key);

  bool containsValue(V value) => _reverse.containsKey(value);

  V? remove(K key) {
    final value = _forward.remove(key);
    if (value != null) _reverse.remove(value);
    return value;
  }

  void clear() {
    _forward.clear();
    _reverse.clear();
  }

  Set<K> keySet() => Set<K>.from(_forward.keys);

  bool get isEmpty => _forward.isEmpty;

  int get size => _forward.length;
}
