// A map that returns a default value when a key is not found.
class DefaultMap<K, V> {
  final Map<K, V> _map = {};
  final V Function() _defaultFactory;

  DefaultMap(this._defaultFactory);

  V get(K key) => _map.putIfAbsent(key, _defaultFactory);

  V? getOrNull(K key) => _map[key];

  void put(K key, V value) => _map[key] = value;

  bool containsKey(K key) => _map.containsKey(key);

  V? remove(K key) => _map.remove(key);

  Set<K> keySet() => Set<K>.from(_map.keys);

  Iterable<V> get values => _map.values;

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;

  int get size => _map.length;
}
