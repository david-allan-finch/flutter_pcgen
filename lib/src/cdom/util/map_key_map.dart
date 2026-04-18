import '../enumeration/map_key.dart';

// A map of maps keyed by MapKey.
class MapKeyMap {
  final Map<MapKey<dynamic, dynamic>, Map<dynamic, dynamic>> _map = {};

  dynamic addToMapFor<K, V>(MapKey<K, V> mapKey, K key, V value) {
    final inner = _map.putIfAbsent(mapKey, () => <K, V>{}) as Map<K, V>;
    return inner[key] = value;
  }

  bool removeFromMapFor<K, V>(MapKey<K, V> mapKey, K key) {
    final inner = _map[mapKey] as Map<K, V>?;
    if (inner == null) return false;
    final had = inner.containsKey(key);
    inner.remove(key);
    if (inner.isEmpty) _map.remove(mapKey);
    return had;
  }

  Map<K, V>? removeMapFor<K, V>(MapKey<K, V> mapKey) {
    return _map.remove(mapKey) as Map<K, V>?;
  }

  Map<K, V> getMapFor<K, V>(MapKey<K, V> mapKey) {
    return (_map[mapKey] as Map<K, V>?) ?? {};
  }

  Set<K> getKeysFor<K, V>(MapKey<K, V> mapKey) {
    final inner = _map[mapKey] as Map<K, V>?;
    if (inner == null) return {};
    return Set.unmodifiable(inner.keys);
  }

  V? get<K, V>(MapKey<K, V> mapKey, K key2) {
    return (_map[mapKey] as Map<K, V>?)?[key2];
  }

  bool containsMapFor<K, V>(MapKey<K, V> mapKey) => _map.containsKey(mapKey);

  Set<MapKey<dynamic, dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
