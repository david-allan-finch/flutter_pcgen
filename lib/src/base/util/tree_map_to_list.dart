import 'dart:collection' show SetBase;
import 'package:flutter_pcgen/src/base/util/abstract_map_to_list.dart';

// A MapToList backed by a sorted (TreeMap-like) map.
class TreeMapToList<K extends Comparable<K>, V> extends AbstractMapToList<K, V> {
  TreeMapToList() : super(SplayTreeMap<K, List<V>>._());

  @override
  Set<K> getEmptySet() => SplayTreeSet<K>();
}

// Simple sorted map implementation
class SplayTreeMap<K extends Comparable<K>, V> implements Map<K, V> {
  final Map<K, V> _inner = {};

  SplayTreeMap._();

  @override
  V? operator [](Object? key) => _inner[key];

  @override
  void operator []=(K key, V value) => _inner[key] = value;

  @override
  void addAll(Map<K, V> other) => _inner.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) =>
      _inner.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  void clear() => _inner.clear();

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _inner.entries;

  @override
  void forEach(void Function(K key, V value) action) => _inner.forEach(action);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<K> get keys {
    final sorted = _inner.keys.toList()..sort();
    return sorted;
  }

  @override
  int get length => _inner.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) =>
      _inner.map(convert);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) =>
      _inner.putIfAbsent(key, ifAbsent);

  @override
  V? remove(Object? key) => _inner.remove(key);

  @override
  void removeWhere(bool Function(K key, V value) test) =>
      _inner.removeWhere(test);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _inner.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K key, V value) update) =>
      _inner.updateAll(update);

  @override
  Iterable<V> get values => _inner.values;
}

class SplayTreeSet<K extends Comparable<K>> extends SetBase<K> {
  final Set<K> _inner = {};

  @override
  bool add(K value) => _inner.add(value);

  @override
  bool contains(Object? element) => _inner.contains(element);

  @override
  bool remove(Object? value) => _inner.remove(value);

  @override
  int get length => _inner.length;

  @override
  Iterator<K> get iterator {
    final sorted = _inner.toList()..sort();
    return sorted.iterator;
  }

  @override
  K? lookup(Object? object) => _inner.lookup(object);

  @override
  Set<K> toSet() => SplayTreeSet<K>()..addAll(_inner);
}
