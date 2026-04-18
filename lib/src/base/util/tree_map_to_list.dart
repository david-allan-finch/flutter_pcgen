import 'abstract_map_to_list.dart';

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

class SplayTreeSet<K extends Comparable<K>> implements Set<K> {
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
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterator<K> get iterator {
    final sorted = _inner.toList()..sort();
    return sorted.iterator;
  }

  @override
  Set<K> toSet() => Set<K>.from(_inner);

  @override
  void clear() => _inner.clear();

  @override
  void addAll(Iterable<K> elements) => _inner.addAll(elements);

  @override
  void removeAll(Iterable<Object?> elements) => _inner.removeAll(elements);

  @override
  bool containsAll(Iterable<Object?> other) => _inner.containsAll(other);

  @override
  Set<K> intersection(Set<Object?> other) => _inner.intersection(other);

  @override
  Set<K> union(Set<K> other) => _inner.union(other);

  @override
  Set<K> difference(Set<Object?> other) => _inner.difference(other);

  @override
  void retainAll(Iterable<Object?> elements) => _inner.retainAll(elements);

  @override
  void retainWhere(bool Function(K element) test) => _inner.retainWhere(test);

  @override
  void removeWhere(bool Function(K element) test) => _inner.removeWhere(test);

  @override
  K get first => (_inner.toList()..sort()).first;

  @override
  K get last => (_inner.toList()..sort()).last;

  @override
  K get single => _inner.single;

  @override
  K elementAt(int index) => (_inner.toList()..sort())[index];

  @override
  K? lookup(Object? object) => _inner.lookup(object);

  @override
  List<K> toList({bool growable = true}) =>
      (_inner.toList()..sort());

  @override
  Iterable<K> where(bool Function(K element) test) => _inner.where(test);

  @override
  Iterable<E> map<E>(E Function(K e) f) => _inner.map(f);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(K element) f) => _inner.expand(f);

  @override
  bool every(bool Function(K element) test) => _inner.every(test);

  @override
  bool any(bool Function(K element) test) => _inner.any(test);

  @override
  void forEach(void Function(K element) f) => _inner.forEach(f);

  @override
  K reduce(K Function(K value, K element) combine) => _inner.reduce(combine);

  @override
  E fold<E>(E initialValue, E Function(E previousValue, K element) combine) =>
      _inner.fold(initialValue, combine);

  @override
  String join([String separator = '']) => _inner.join(separator);

  @override
  K firstWhere(bool Function(K element) test, {K Function()? orElse}) =>
      _inner.firstWhere(test, orElse: orElse!);

  @override
  K lastWhere(bool Function(K element) test, {K Function()? orElse}) =>
      _inner.lastWhere(test, orElse: orElse!);

  @override
  K singleWhere(bool Function(K element) test, {K Function()? orElse}) =>
      _inner.singleWhere(test, orElse: orElse!);

  @override
  Iterable<K> skip(int count) => _inner.skip(count);

  @override
  Iterable<K> skipWhile(bool Function(K value) test) => _inner.skipWhile(test);

  @override
  Iterable<K> take(int count) => _inner.take(count);

  @override
  Iterable<K> takeWhile(bool Function(K value) test) => _inner.takeWhile(test);

  @override
  Iterable<K> followedBy(Iterable<K> other) => _inner.followedBy(other);

  @override
  Iterable<K> cast<K>() => _inner.cast<K>();
}
