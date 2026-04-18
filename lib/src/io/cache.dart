// Translation of pcgen.io.Cache

/// Cache wraps a Map<String, List<String>> for LST export processing.
class Cache {
  final Map<String, List<String>> _map = {};

  bool containsKey(String key) => _map.containsKey(key);

  List<String>? get(String key) => _map[key];

  void put(String key, List<String> value) => _map[key] = value;

  void add(String key, String value) =>
      _map.putIfAbsent(key, () => []).add(value);

  Set<String> get keys => _map.keys.toSet();
}
