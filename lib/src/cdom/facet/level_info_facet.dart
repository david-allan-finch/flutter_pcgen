// Copyright (c) Thomas Parker, 2010-2012.
//
// Translation of pcgen.cdom.facet.LevelInfoFacet

import '../enumeration/char_id.dart';
import '../../core/pclevelinfo/pc_level_info.dart';
import 'base/abstract_list_facet.dart';

/// Stores the [PCLevelInfo] objects for a Player Character in insertion order.
/// The implicit index of each item represents its level.
class LevelInfoFacet extends AbstractListFacet<CharID, PCLevelInfo> {
  /// Use a [List]-backed set so that iteration order is stable (insertion order).
  @override
  Set<PCLevelInfo> getComponentSet() => _OrderedSet<PCLevelInfo>();

  /// Returns the [PCLevelInfo] at the given [location] (0-based).
  PCLevelInfo? getItemAt(CharID id, int location) {
    final set = getCachedSet(id);
    if (set == null) return null;
    final list = set.toList();
    if (location < 0 || location >= list.length) return null;
    return list[location];
  }
}

/// A [Set] that preserves insertion order (delegates to a [List]).
class _OrderedSet<E> implements Set<E> {
  final List<E> _list = [];

  @override
  bool add(E value) {
    if (_list.contains(value)) return false;
    _list.add(value);
    return true;
  }

  @override
  bool remove(Object? value) => _list.remove(value);

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  int get length => _list.length;

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  void addAll(Iterable<E> elements) {
    for (final e in elements) add(e);
  }

  @override
  void clear() => _list.clear();

  @override
  bool containsAll(Iterable<Object?> other) => other.every(contains);

  @override
  Set<E> difference(Set<Object?> other) =>
      _OrderedSet<E>()..addAll(_list.where((e) => !other.contains(e)));

  @override
  Set<E> intersection(Set<Object?> other) =>
      _OrderedSet<E>()..addAll(_list.where(other.contains));

  @override
  E? lookup(Object? object) =>
      _list.firstWhere((e) => e == object, orElse: () => null as dynamic);

  @override
  void removeAll(Iterable<Object?> elements) {
    for (final e in elements) remove(e);
  }

  @override
  void removeWhere(bool Function(E) test) => _list.removeWhere(test);

  @override
  void retainAll(Iterable<Object?> elements) =>
      _list.retainWhere((e) => elements.contains(e));

  @override
  void retainWhere(bool Function(E) test) => _list.retainWhere(test);

  @override
  Set<E> union(Set<E> other) => _OrderedSet<E>()
    ..addAll(_list)
    ..addAll(other);

  @override
  List<E> toList({bool growable = true}) => List.of(_list, growable: growable);

  @override
  Set<E> toSet() => _OrderedSet<E>()..addAll(_list);

  // Iterable delegation
  @override
  Set<R> cast<R>() => throw UnimplementedError();
  @override
  Iterable<T> expand<T>(Iterable<T> Function(E) f) => _list.expand(f);
  @override
  E firstWhere(bool Function(E) t, {E Function()? orElse}) =>
      _list.firstWhere(t, orElse: orElse);
  @override
  T fold<T>(T init, T Function(T, E) c) => _list.fold(init, c);
  @override
  void forEach(void Function(E) f) => _list.forEach(f);
  @override
  String join([String sep = '']) => _list.join(sep);
  @override
  E lastWhere(bool Function(E) t, {E Function()? orElse}) =>
      _list.lastWhere(t, orElse: orElse);
  @override
  Iterable<T> map<T>(T Function(E) f) => _list.map(f);
  @override
  E reduce(E Function(E, E) c) => _list.reduce(c);
  @override
  E get single => _list.single;
  @override
  E get first => _list.first;
  @override
  E get last => _list.last;
  @override
  E singleWhere(bool Function(E) t, {E Function()? orElse}) =>
      _list.singleWhere(t, orElse: orElse);
  @override
  Iterable<E> skip(int n) => _list.skip(n);
  @override
  Iterable<E> skipWhile(bool Function(E) t) => _list.skipWhile(t);
  @override
  Iterable<E> take(int n) => _list.take(n);
  @override
  Iterable<E> takeWhile(bool Function(E) t) => _list.takeWhile(t);
  @override
  Iterable<E> where(bool Function(E) t) => _list.where(t);
  @override
  Iterable<T> whereType<T>() => _list.whereType<T>();
  @override
  bool any(bool Function(E) t) => _list.any(t);
  @override
  bool every(bool Function(E) t) => _list.every(t);
  @override
  Iterable<T> followedBy<T>(Iterable<T> other) => throw UnimplementedError();
}
