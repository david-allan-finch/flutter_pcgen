enum MapEventType {
  keyAdded,
  keyRemoved,
  keyModified,
  valueChanged,
  valueModified,
  keysChanged,
}

class MapEvent<K, V> {
  final Object source;
  final MapEventType type;
  final K? key;
  final V? oldValue;
  final V? newValue;

  const MapEvent(this.source, this.type, this.key, this.oldValue, this.newValue);

  const MapEvent.keysChanged(this.source)
      : type = MapEventType.keysChanged,
        key = null,
        oldValue = null,
        newValue = null;
}

abstract interface class MapListener<K, V> {
  void keyAdded(MapEvent<K, V> e);
  void keyRemoved(MapEvent<K, V> e);
  void keyModified(MapEvent<K, V> e);
  void valueChanged(MapEvent<K, V> e);
  void valueModified(MapEvent<K, V> e);
  void keysChanged(MapEvent<K, V> e);
}
