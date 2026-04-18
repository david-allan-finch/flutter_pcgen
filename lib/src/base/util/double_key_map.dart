class DoubleKeyMap<K1, K2, V> {
  final Map<K1, Map<K2, V>> _map = {};
  bool _cleanup = true;

  V? put(K1 key1, K2 key2, V value) {
    _map.putIfAbsent(key1, () => {});
    final old = _map[key1]![key2];
    _map[key1]![key2] = value;
    return old;
  }

  void putAll(DoubleKeyMap<K1, K2, V> dkm) {
    for (final entry in dkm._map.entries) {
      _map.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
  }

  V? computeIfAbsent(K1 key1, K2 key2, V Function(K1, K2) mappingFunction) {
    _map.putIfAbsent(key1, () => {});
    return _map[key1]!.putIfAbsent(key2, () => mappingFunction(key1, key2));
  }

  V? get(K1 key1, K2 key2) => _map[key1]?[key2];

  Map<K2, V> getMapFor(K1 key1) => Map<K2, V>.from(_map[key1] ?? {});

  bool containsKey1(K1 key1) => _map.containsKey(key1);

  bool containsKey(K1 key1, K2 key2) =>
      _map[key1]?.containsKey(key2) ?? false;

  V? remove(K1 key1, K2 key2) {
    final localMap = _map[key1];
    if (localMap == null) return null;
    final removed = localMap.remove(key2);
    if (_cleanup && localMap.isEmpty) _map.remove(key1);
    return removed;
  }

  Map<K2, V>? removeAll(K1 key1) => _map.remove(key1);

  Set<K1> getKeySet() => Set<K1>.from(_map.keys);

  Set<K2> getSecondaryKeySet(K1 key1) {
    final localMap = _map[key1];
    return localMap == null ? <K2>{} : Set<K2>.from(localMap.keys);
  }

  void clear() {
    _cleanup = true;
    _map.clear();
  }

  Set<V> values(K1 key1) {
    final localMap = _map[key1];
    return localMap == null ? <V>{} : Set<V>.from(localMap.values);
  }

  bool get isEmpty => _map.isEmpty;

  int primaryKeyCount() => _map.length;

  bool removeValue(K1 key1, V obj) {
    final localMap = _map[key1];
    if (localMap == null) return false;
    final key = localMap.entries
        .where((e) => e.value == obj)
        .map((e) => e.key)
        .firstOrNull;
    if (key == null) return false;
    localMap.remove(key);
    return true;
  }

  Map<K2, V> getReadOnlyMapFor(K1 key1) {
    _cleanup = false;
    _map.putIfAbsent(key1, () => {});
    return Map.unmodifiable(_map[key1]!);
  }

  DoubleKeyMap<K1, K2, V> clone() {
    final dkm = DoubleKeyMap<K1, K2, V>();
    for (final entry in _map.entries) {
      if (entry.value.isNotEmpty) {
        dkm._map[entry.key] = Map<K2, V>.from(entry.value);
      }
    }
    return dkm;
  }

  @override
  int get hashCode => _map.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is DoubleKeyMap && _map == obj._map;
}
