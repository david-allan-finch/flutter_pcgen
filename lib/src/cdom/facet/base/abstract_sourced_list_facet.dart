// Copyright (c) Thomas Parker, 2009-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';

// dynamic: CDOMObject (not yet translated - used in getCountFrom / containsFrom)

/// An AbstractSourcedListFacet is a DataFacet that contains information about
/// Objects that are contained in a resource when the source of that object
/// should be tracked.
///
/// Each Object may only be contained one time by the resource, even if received
/// from multiple sources. Uses identity comparison for sources.
abstract class AbstractSourcedListFacet<IDT extends PCGenIdentifier, T>
    extends AbstractDataFacet<IDT, T> {
  /// Adds the given object with the given source for the given id.
  void add(IDT id, T obj, Object? source) {
    final map = _getConstructingCachedMap(id);
    Set<Object?>? set = map[obj];
    final fireNew = set == null;
    if (fireNew) {
      set = _newIdentitySet();
      map[obj] = set;
    }
    set!.add(source);
    if (fireNew) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
    }
  }

  /// Adds all objects in [c] with the given source.
  void addAll(IDT id, Iterable<T> c, Object? source) {
    for (final obj in c) {
      add(id, obj, source);
    }
  }

  /// Removes the given source from the object. If it was the last source,
  /// the object is removed. Returns true if the source was removed.
  bool remove(IDT id, T obj, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return false;
    return _processRemoval(id, componentMap, obj, source);
  }

  /// Removes the given source from all objects in [c].
  void removeAll(IDT id, Iterable<T> c, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final obj in c) {
        _processRemoval(id, componentMap, obj, source);
      }
    }
  }

  /// Removes all objects (and all sources) for the given id.
  /// Returns the old map.
  Map<T, Set<Object?>> removeAllObjects(IDT id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return {};
    removeCache(id);
    for (final obj in componentMap.keys.toList()) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
    }
    return componentMap;
  }

  /// Returns an unmodifiable set of all objects for the given id.
  Set<T> getSet(IDT id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return <T>{};
    return Set.unmodifiable(componentMap.keys.toSet());
  }

  /// Returns the count of items for the given id.
  int getCount(IDT id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return 0;
    return componentMap.length;
  }

  /// Returns true if no items exist for the given id.
  bool isEmpty(IDT id) {
    final componentMap = getCachedMap(id);
    return componentMap == null || componentMap.isEmpty;
  }

  /// Returns true if the facet contains the given object for the given id.
  bool contains(IDT id, T obj) {
    final componentMap = getCachedMap(id);
    return componentMap != null && componentMap.containsKey(obj);
  }

  /// Returns the map from cache (may be null).
  Map<T, Set<Object?>>? getCachedMap(IDT id) {
    return getCache(id) as Map<T, Set<Object?>>?;
  }

  Map<T, Set<Object?>> _getConstructingCachedMap(IDT id) {
    Map<T, Set<Object?>>? componentMap = getCachedMap(id);
    if (componentMap == null) {
      componentMap = getComponentMap();
      setCache(id, componentMap);
    }
    return componentMap;
  }

  Set<Object?> _getConstructingCachedSetFor(IDT id, T obj) {
    final map = _getConstructingCachedMap(id);
    return map.putIfAbsent(obj, () => _newIdentitySet());
  }

  /// Returns a new empty Map. Override to use a different map type.
  Map<T, Set<Object?>> getComponentMap() {
    // Dart has no IdentityHashMap, use regular Map (object identity via identical)
    return <T, Set<Object?>>{};
  }

  Set<Object?> _newIdentitySet() {
    // Dart has no identity set built-in; use a List-backed set for identity semantics
    return _IdentitySet<Object?>();
  }

  @override
  void copyContents(IDT source, IDT destination) {
    final sourceMap = getCachedMap(source);
    if (sourceMap != null) {
      for (final entry in sourceMap.entries) {
        final targetSet = _getConstructingCachedSetFor(destination, entry.key);
        targetSet.addAll(entry.value);
      }
    }
  }

  bool _processRemoval(
      IDT id, Map<T, Set<Object?>> componentMap, T obj, Object? source) {
    final set = componentMap[obj];
    if (set == null) return false;
    final returnVal = set.remove(source);
    if (set.isEmpty) {
      componentMap.remove(obj);
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      if (componentMap.isEmpty) {
        removeCache(id);
      }
    }
    return returnVal;
  }

  /// Removes all information for the given source from this facet for the given id.
  void removeAllFromSource(IDT id, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      final removedKeys = <T>[];
      for (final entry in componentMap.entries.toList()) {
        final set = entry.value;
        if (set.remove(source) && set.isEmpty) {
          componentMap.remove(entry.key);
          removedKeys.add(entry.key);
        }
      }
      if (componentMap.isEmpty) {
        removeCache(id);
      }
      for (final obj in removedKeys) {
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      }
    }
  }

  /// Returns objects granted by the given source owner.
  List<T> getSetForOwner(IDT id, Object? owner) {
    final list = <T>[];
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        if (entry.value.contains(owner)) {
          list.add(entry.key);
        }
      }
    }
    return List.unmodifiable(list);
  }

  /// Returns true if any item from the given source exists for the given id.
  bool containsFrom(IDT id, Object? owner) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final set in componentMap.values) {
        if (set.contains(owner)) return true;
      }
    }
    return false;
  }

  /// Returns count of items granted by the given CDOMObject owner.
  int getCountFrom(IDT id, dynamic owner) {
    final componentMap = getCachedMap(id);
    int count = 0;
    if (componentMap != null) {
      for (final set in componentMap.values) {
        if (set.contains(owner)) count++;
      }
    }
    return count;
  }

  /// Returns true if the given object is granted by the given owner.
  bool containsFromOwner(IDT id, T obj, dynamic owner) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      final sources = componentMap[obj];
      return sources != null && sources.contains(owner);
    }
    return false;
  }

  /// Returns unmodifiable collection of sources for the given object.
  Iterable<Object?> getSources(IDT id, T obj) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      final sources = componentMap[obj];
      if (sources != null) {
        return List.unmodifiable(sources.toList());
      }
    }
    return const [];
  }
}

/// A simple identity-based Set (uses identical() for equality).
class _IdentitySet<E> implements Set<E> {
  final List<E> _list = [];

  @override
  bool add(E value) {
    for (final e in _list) {
      if (identical(e, value)) return false;
    }
    _list.add(value);
    return true;
  }

  @override
  bool remove(Object? value) {
    for (int i = 0; i < _list.length; i++) {
      if (identical(_list[i], value)) {
        _list.removeAt(i);
        return true;
      }
    }
    return false;
  }

  @override
  bool contains(Object? element) {
    for (final e in _list) {
      if (identical(e, element)) return true;
    }
    return false;
  }

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
  bool containsAll(Iterable<Object?> other) =>
      other.every((e) => contains(e));

  @override
  Set<E> difference(Set<Object?> other) {
    final result = _IdentitySet<E>();
    for (final e in _list) {
      if (!other.contains(e)) result.add(e);
    }
    return result;
  }

  @override
  Set<E> intersection(Set<Object?> other) {
    final result = _IdentitySet<E>();
    for (final e in _list) {
      if (other.contains(e)) result.add(e);
    }
    return result;
  }

  @override
  E? lookup(Object? object) {
    for (final e in _list) {
      if (identical(e, object)) return e;
    }
    return null;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    for (final e in elements) remove(e);
  }

  @override
  void removeWhere(bool Function(E element) test) {
    _list.removeWhere(test);
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    _list.retainWhere((e) => elements.any((o) => identical(o, e)));
  }

  @override
  void retainWhere(bool Function(E element) test) {
    _list.retainWhere(test);
  }

  @override
  Set<E> union(Set<E> other) {
    final result = _IdentitySet<E>();
    result.addAll(_list);
    result.addAll(other);
    return result;
  }

  @override
  Set<R> cast<R>() => throw UnimplementedError();

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) =>
      _list.expand(toElements);

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) =>
      _list.fold(initialValue, combine);

  @override
  void forEach(void Function(E element) action) => _list.forEach(action);

  @override
  String join([String separator = '']) => _list.join(separator);

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => _list.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => _list.reduce(combine);

  @override
  E get single => _list.single;

  @override
  E get first => _list.first;

  @override
  E get last => _list.last;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) =>
      _list.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _list.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) =>
      _list.skipWhile(test);

  @override
  Iterable<E> take(int count) => _list.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) =>
      _list.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => List.of(_list, growable: growable);

  @override
  Set<E> toSet() {
    final s = _IdentitySet<E>();
    s.addAll(_list);
    return s;
  }

  @override
  Iterable<E> where(bool Function(E element) test) => _list.where(test);

  @override
  Iterable<T> whereType<T>() => _list.whereType<T>();

  @override
  bool any(bool Function(E element) test) => _list.any(test);

  @override
  bool every(bool Function(E element) test) => _list.every(test);

  @override
  Iterable<T> followedBy<T>(Iterable<T> other) =>
      throw UnimplementedError();
}
