import 'event/map_event.dart';
import 'map_facade.dart';

abstract class AbstractMapFacade<K, V> implements MapFacade<K, V> {
  final List<MapListener<K, V>> _listeners = [];

  @override
  void addMapListener(MapListener<K, V> listener) {
    _listeners.add(listener);
  }

  @override
  void removeMapListener(MapListener<K, V> listener) {
    _listeners.remove(listener);
  }

  @override
  int getSize() => getKeys().length;

  @override
  bool containsKey(K key) => getKeys().contains(key);

  @override
  bool isEmpty() => getKeys().isEmpty;

  void fireKeyAdded(Object source, K key, V value) {
    final e = MapEvent<K, V>(source, MapEventType.keyAdded, key, null, value);
    for (final l in List.of(_listeners)) l.keyAdded(e);
  }

  void fireKeyRemoved(Object source, K key, V value) {
    final e = MapEvent<K, V>(source, MapEventType.keyRemoved, key, value, null);
    for (final l in List.of(_listeners)) l.keyRemoved(e);
  }

  void fireKeyModified(Object source, K key, V value) {
    final e =
        MapEvent<K, V>(source, MapEventType.keyModified, key, value, value);
    for (final l in List.of(_listeners)) l.keyModified(e);
  }

  void fireValueChanged(Object source, K key, V oldValue, V newValue) {
    final e = MapEvent<K, V>(
        source, MapEventType.valueChanged, key, oldValue, newValue);
    for (final l in List.of(_listeners)) l.valueChanged(e);
  }

  void fireValueModified(Object source, K key, V value) {
    final e =
        MapEvent<K, V>(source, MapEventType.valueModified, key, value, value);
    for (final l in List.of(_listeners)) l.valueModified(e);
  }

  void fireKeysChanged(Object source) {
    final e = MapEvent<K, V>.keysChanged(source);
    for (final l in List.of(_listeners)) l.keysChanged(e);
  }
}
