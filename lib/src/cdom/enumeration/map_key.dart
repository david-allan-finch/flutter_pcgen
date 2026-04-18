// Typesafe key for Map storage in CDOMObject.
class MapKey<K, V> {
  static final Map<String, MapKey<dynamic, dynamic>> _registry = {};

  final String? _name;

  MapKey._([this._name]);

  // Named factory for registration
  static MapKey<K, V> named<K, V>(String name) {
    final existing = _registry[name];
    if (existing != null) return existing as MapKey<K, V>;
    final key = MapKey<K, V>._(name);
    _registry[name] = key;
    return key;
  }

  @override
  String toString() => _name ?? 'MapKey<$K,$V>';
}
