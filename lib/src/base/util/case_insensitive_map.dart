import '../lang/case_insensitive_string.dart';

// A Map that compares String keys case-insensitively.
class CaseInsensitiveMap<V> {
  final Map<CaseInsensitiveString, V> _map = {};

  V? put(String key, V value) {
    final k = CaseInsensitiveString(key);
    final old = _map[k];
    _map[k] = value;
    return old;
  }

  V? get(String key) => _map[CaseInsensitiveString(key)];

  bool containsKey(String key) => _map.containsKey(CaseInsensitiveString(key));

  V? remove(String key) => _map.remove(CaseInsensitiveString(key));

  Set<String> keySet() => _map.keys.map((k) => k.toString()).toSet();

  Iterable<V> get values => _map.values;

  void clear() => _map.clear();

  bool get isEmpty => _map.isEmpty;

  int get size => _map.length;

  void forEach(void Function(String key, V value) action) {
    _map.forEach((k, v) => action(k.toString(), v));
  }
}
