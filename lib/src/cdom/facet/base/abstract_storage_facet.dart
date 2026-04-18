// Copyright (c) 2012 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../base/pc_gen_identifier.dart';

/// A DoubleKeyMap replacement: stores cache keyed by (PCGenIdentifier, runtimeType).
/// In Dart we use a Map<PCGenIdentifier, Map<Type, Object>> at the class level.
final Map<PCGenIdentifier, Map<Type, Object?>> _cache = {};

/// An AbstractStorageFacet is a facet which stores contents in the overall CDOM
/// cache. All classes (facets) that want to store information in the cache must
/// extend this class.
abstract class AbstractStorageFacet<T extends PCGenIdentifier> {
  /// Removes the information from the cache for a given resource and facet.
  Object? removeCache(T id) {
    final inner = _cache[id];
    if (inner == null) return null;
    final val = inner.remove(runtimeType);
    if (inner.isEmpty) {
      _cache.remove(id);
    }
    return val;
  }

  /// Sets the information in the cache for a given resource and facet.
  Object? setCache(T id, Object? o) {
    final inner = _cache.putIfAbsent(id, () => {});
    final old = inner[runtimeType];
    inner[runtimeType] = o;
    return old;
  }

  /// Retrieves the information from the cache for a given resource and facet.
  Object? getCache(T id) {
    return _cache[id]?[runtimeType];
  }

  /// Tests whether the contents of the cache are equal for two resources.
  /// Uses an InequalityTester (dynamic) to compare cache contents.
  static bool areEqualCache(
      PCGenIdentifier id1, PCGenIdentifier id2, dynamic t) {
    final set1 = _cache[id1]?.keys.toSet() ?? <Type>{};
    final set2 = _cache[id2]?.keys.toSet() ?? <Type>{};
    if (!setEquals(set1, set2)) {
      final l1 = set1.difference(set2).toList();
      final l2 = set2.difference(set1).toList();
      // Logging.errorPrint equivalent
      print('Inequal: $l1 $l2');
      return false;
    }
    for (final cl in set1) {
      final obj1 = _cache[id1]?[cl];
      final obj2 = _cache[id2]?[cl];
      final String? equal = t.testEquality(obj1, obj2, '$cl/');
      if (equal != null) {
        print(equal);
        return false;
      }
    }
    return true;
  }

  /// Returns a read-only view into the cache for a given PCGenIdentifier.
  static Map<Type, Object?> peekAtCache(PCGenIdentifier id) {
    return Map.unmodifiable(_cache[id] ?? {});
  }

  /// Copies the contents from one resource to another.
  void copyContents(T source, T copy);
}

bool setEquals<E>(Set<E> a, Set<E> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}
