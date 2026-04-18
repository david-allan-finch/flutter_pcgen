import '../enumeration/fact_set_key.dart';

// A map of lists keyed by FactSetKey.
class FactSetKeyMapToList {
  final Map<FactSetKey<dynamic>, List<dynamic>> _map = {};

  bool containsListFor(FactSetKey<dynamic> key) => _map.containsKey(key);

  void addToListFor<T>(FactSetKey<T> key, dynamic element) {
    _map.putIfAbsent(key, () => []).add(element);
  }

  void addAllToListFor<T>(FactSetKey<T> key, Iterable<dynamic> elements) {
    _map.putIfAbsent(key, () => []).addAll(elements);
  }

  List<dynamic>? getListFor<T>(FactSetKey<T> key) {
    final list = _map[key];
    if (list == null) return null;
    return List.from(list);
  }

  int sizeOfListFor(FactSetKey<dynamic> key) {
    return _map[key]?.length ?? 0;
  }

  bool containsInList<T>(FactSetKey<T> key, dynamic element) {
    return _map[key]?.contains(element) ?? false;
  }

  bool containsAnyInList<T>(FactSetKey<T> key, Iterable<dynamic> elements) {
    final list = _map[key];
    if (list == null) return false;
    return elements.any((e) => list.contains(e));
  }

  List<dynamic>? removeListFor<T>(FactSetKey<T> key) {
    return _map.remove(key);
  }

  bool removeFromListFor<T>(FactSetKey<T> key, dynamic element) {
    final list = _map[key];
    if (list == null) return false;
    final removed = list.remove(element);
    if (list.isEmpty) _map.remove(key);
    return removed;
  }

  Set<FactSetKey<dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
