import 'abstract_map_facade.dart';

class DefaultMapFacade<K, V> extends AbstractMapFacade<K, V> {
  final Map<K, V> _map;

  DefaultMapFacade() : _map = {};

  DefaultMapFacade.from(Map<K, V> map) : _map = Map.of(map);

  @override
  Set<K> getKeys() => Set.unmodifiable(_map.keys.toSet());

  @override
  V? getValue(K key) => _map[key];

  void putValue(K key, V value) {
    final hasKey = _map.containsKey(key);
    final oldValue = _map[key];
    _map[key] = value;
    if (hasKey) {
      fireValueChanged(this, key, oldValue as V, value);
    } else {
      fireKeyAdded(this, key, value);
    }
  }

  void removeKey(K key) {
    if (_map.containsKey(key)) {
      final value = _map.remove(key) as V;
      fireKeyRemoved(this, key, value);
    }
  }

  void setContents(Map<K, V> newMap) {
    _map.clear();
    _map.addAll(newMap);
    fireKeysChanged(this);
  }

  void clear() {
    _map.clear();
    fireKeysChanged(this);
  }

  @override
  String toString() => 'DefaultMapFacade($_map)';
}
