// A deque (double-ended queue) where elements are also indexed by key.
class MappedDeque<K, V> {
  final List<V> _list = [];
  final Map<K, V> _map = {};
  final K Function(V) _keyOf;

  MappedDeque(this._keyOf);

  void addFirst(V value) {
    _list.insert(0, value);
    _map[_keyOf(value)] = value;
  }

  void addLast(V value) {
    _list.add(value);
    _map[_keyOf(value)] = value;
  }

  V? removeFirst() {
    if (_list.isEmpty) return null;
    final value = _list.removeAt(0);
    _map.remove(_keyOf(value));
    return value;
  }

  V? removeLast() {
    if (_list.isEmpty) return null;
    final value = _list.removeLast();
    _map.remove(_keyOf(value));
    return value;
  }

  V? get(K key) => _map[key];

  bool containsKey(K key) => _map.containsKey(key);

  int get size => _list.length;

  bool get isEmpty => _list.isEmpty;

  List<V> toList() => List<V>.from(_list);
}
