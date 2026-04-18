import '../enumeration/list_key.dart';

// A map of lists keyed by ListKey.
class ListKeyMapToList {
  final Map<ListKey<dynamic>, List<dynamic>> _map = {};

  bool containsListFor(ListKey<dynamic> key) => _map.containsKey(key);

  void addToListFor<T>(ListKey<T> key, T element) {
    _map.putIfAbsent(key, () => []).add(element);
  }

  void addAllToListFor<T>(ListKey<T> key, Iterable<T> elements) {
    _map.putIfAbsent(key, () => []).addAll(elements);
  }

  List<T>? getListFor<T>(ListKey<T> key) {
    final list = _map[key];
    if (list == null) return null;
    return List<T>.from(list);
  }

  int sizeOfListFor(ListKey<dynamic> key) {
    return _map[key]?.length ?? 0;
  }

  bool containsInList<T>(ListKey<T> key, T element) {
    return _map[key]?.contains(element) ?? false;
  }

  bool containsAnyInList<T>(ListKey<T> key, Iterable<T> elements) {
    final list = _map[key];
    if (list == null) return false;
    return elements.any((e) => list.contains(e));
  }

  T? getElementInList<T>(ListKey<T> key, int index) {
    final list = _map[key];
    if (list == null || index >= list.length) return null;
    return list[index] as T;
  }

  List<T>? removeListFor<T>(ListKey<T> key) {
    final list = _map.remove(key);
    if (list == null) return null;
    return List<T>.from(list);
  }

  bool removeFromListFor<T>(ListKey<T> key, T element) {
    final list = _map[key];
    if (list == null) return false;
    final removed = list.remove(element);
    if (list.isEmpty) _map.remove(key);
    return removed;
  }

  Set<ListKey<dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
