import 'package:flutter_pcgen/src/base/util/map_to_list.dart';

abstract class AbstractMapToList<K, V> implements MapToList<K, V> {
  final Map<K, List<V>> _mapToList;

  AbstractMapToList(Map<K, List<V>> mtl) : _mapToList = mtl;

  @override
  void initializeListFor(K key) {
    if (_mapToList.containsKey(key)) {
      throw ArgumentError('Cannot re-initialize key: $key');
    }
    _mapToList[key] = [];
  }

  @override
  void addToListFor(K key, V valueElement) {
    if (!containsListFor(key)) initializeListFor(key);
    _mapToList[key]!.add(valueElement);
  }

  void addToListForAt(K key, int location, V valueElement) {
    if (!containsListFor(key)) {
      if (location != 0) {
        throw ArgumentError('Cannot add at location > 0 when list is not initialized');
      }
      initializeListFor(key);
    }
    _mapToList[key]!.insert(location, valueElement);
  }

  @override
  void addAllToListFor(K key, Iterable<V> values) {
    final list = values.toList();
    if (list.isEmpty) return;
    if (!containsListFor(key)) initializeListFor(key);
    _mapToList[key]!.addAll(list);
  }

  @override
  void addAllLists(MapToList<K, V> mtl) {
    for (final key in mtl.getKeySet()) {
      addAllToListFor(key, mtl.getSafeListFor(key));
    }
  }

  @override
  bool containsListFor(K key) => _mapToList.containsKey(key);

  @override
  bool containsInList(K key, V valueElement) =>
      containsListFor(key) && _mapToList[key]!.contains(valueElement);

  bool containsAnyInList(K key, Iterable<V> values) {
    final list = _mapToList[key];
    if (list == null) return false;
    return values.any((v) => list.contains(v));
  }

  @override
  int sizeOfListFor(K key) {
    final list = _mapToList[key];
    return list == null ? 0 : list.length;
  }

  @override
  List<V>? getListFor(K key) {
    final list = _mapToList[key];
    return list == null ? null : List<V>.from(list);
  }

  @override
  List<V> getSafeListFor(K key) => getListFor(key) ?? [];

  @override
  bool removeFromListFor(K key, V valueElement) {
    final list = _mapToList[key];
    if (list == null) return false;
    final removed = list.remove(valueElement);
    if (removed && list.isEmpty) _mapToList.remove(key);
    return removed;
  }

  @override
  List<V>? removeListFor(K key) => _mapToList.remove(key);

  @override
  bool isEmpty() => _mapToList.isEmpty;

  @override
  int size() => _mapToList.length;

  @override
  V getElementInList(K key, int index) {
    final list = _mapToList[key];
    if (list == null) throw StateError('$key is not a key in this MapToList');
    return list[index];
  }

  @override
  void clear() => _mapToList.clear();

  @override
  Set<K> getKeySet() => Set<K>.from(_mapToList.keys);

  @override
  String toString() => _mapToList.toString();

  @override
  int get hashCode => _mapToList.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is AbstractMapToList && _mapToList == obj._mapToList;

  Set<K> getEmptySet();
}
