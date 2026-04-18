// Copyright (c) Thomas Parker, 2013.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../enumeration/char_id.dart';
import '../event/data_facet_change_event.dart';
import 'abstract_data_facet.dart';

// dynamic: QualifyingObject, QualifiedActor, PrerequisiteFacet, FacetLibrary
// (not yet translated)

/// An AbstractQualifiedListFacet is a DataFacet that contains information about
/// QualifyingObjects that are contained in a PlayerCharacter when the source of
/// that object should be tracked, and the PlayerCharacter can qualify for the
/// object (they have prerequisites).
abstract class AbstractQualifiedListFacet<T>
    extends AbstractDataFacet<CharID, T> {
  // stub: PrerequisiteFacet prereqFacet = FacetLibrary.getFacet(PrerequisiteFacet.class);
  dynamic _prereqFacet; // stub

  /// Adds the given object with the given source.
  void add(CharID id, T obj, Object? source) {
    final map = _getConstructingCachedMap(id);
    Set<Object?>? set = map[obj];
    final fireNew = set == null;
    if (fireNew) {
      set = <Object?>{};
      map[obj] = set;
    }
    set!.add(source);
    if (fireNew) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
    }
  }

  /// Adds all objects in [c] with the given source.
  void addAll(CharID id, Iterable<T> c, Object? source) {
    for (final obj in c) {
      add(id, obj, source);
    }
  }

  /// Removes the given source for the given object.
  void remove(CharID id, T obj, Object? source) {
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      _processRemoval(id, componentMap, obj, source);
    }
  }

  /// Removes the given source from all objects in [c].
  void removeAll(CharID id, Iterable<T> c, Object? source) {
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      for (final obj in c) {
        _processRemoval(id, componentMap, obj, source);
      }
    }
  }

  /// Removes all objects (and sources) for the given id. Returns old map.
  Map<T, Set<Object?>> removeAllObjects(CharID id) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return {};
    removeCache(id);
    for (final obj in componentMap.keys.toList()) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
    }
    return componentMap;
  }

  /// Returns unmodifiable set of all objects for the given id.
  Set<T> getSet(CharID id) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return <T>{};
    return Set.unmodifiable(componentMap.keys.toSet());
  }

  /// Returns the count of items for the given id.
  int getCount(CharID id) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return 0;
    return componentMap.length;
  }

  /// Returns true if no items exist for the given id.
  bool isEmpty(CharID id) {
    final componentMap = _getCachedMap(id);
    return componentMap == null || componentMap.isEmpty;
  }

  /// Returns true if the facet contains the given object for the given id.
  bool contains(CharID id, T obj) {
    final componentMap = _getCachedMap(id);
    return componentMap != null && componentMap.containsKey(obj);
  }

  Map<T, Set<Object?>>? _getCachedMap(CharID id) {
    return getCache(id) as Map<T, Set<Object?>>?;
  }

  Set<Object?> _getConstructingCachedSetFor(CharID id, T obj) {
    final map = _getConstructingCachedMap(id);
    return map.putIfAbsent(obj, () => <Object?>{});
  }

  Map<T, Set<Object?>> _getConstructingCachedMap(CharID id) {
    Map<T, Set<Object?>>? componentMap = _getCachedMap(id);
    if (componentMap == null) {
      componentMap = getComponentMap();
      setCache(id, componentMap);
    }
    return componentMap;
  }

  /// Returns a new empty Map for storage. Override for custom map types.
  Map<T, Set<Object?>> getComponentMap() {
    return <T, Set<Object?>>{};
  }

  @override
  void copyContents(CharID source, CharID destination) {
    final sourceMap = _getCachedMap(source);
    if (sourceMap != null) {
      for (final entry in sourceMap.entries) {
        final targetSet = _getConstructingCachedSetFor(destination, entry.key);
        targetSet.addAll(entry.value);
      }
    }
  }

  void _processRemoval(
      CharID id, Map<T, Set<Object?>> componentMap, T obj, Object? source) {
    final set = componentMap[obj];
    if (set != null) {
      set.remove(source);
      if (set.isEmpty) {
        componentMap.remove(obj);
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      }
    }
  }

  /// Removes all information for the given source for the given id.
  void removeAllFromSource(CharID id, Object? source) {
    final componentMap = _getCachedMap(id);
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

  /// Returns objects granted by the given owner source.
  List<T> getSetForOwner(CharID id, Object? owner) {
    final list = <T>[];
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        if (entry.value.contains(owner)) {
          list.add(entry.key);
        }
      }
    }
    return list;
  }

  /// Returns objects the character qualifies for (checks prerequisites via prereqFacet).
  Set<T> getQualifiedSet(CharID id) {
    final set = <T>{};
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        final obj = entry.key;
        final sources = entry.value;
        for (final source in sources) {
          // stub: prereqFacet.qualifies(id, obj, source)
          if (_prereqFacet?.qualifies(id, obj, source) == true) {
            set.add(obj);
            break;
          }
        }
      }
    }
    return set;
  }

  /// Returns objects the character qualifies for granted by the given source.
  Set<T> getQualifiedSetForSource(CharID id, Object? source) {
    final set = <T>{};
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        final obj = entry.key;
        final sources = entry.value;
        if (sources.contains(source)) {
          // stub: prereqFacet.qualifies(id, obj, source)
          if (_prereqFacet?.qualifies(id, obj, source) == true) {
            set.add(obj);
          }
        }
      }
    }
    return set;
  }

  /// Acts on all qualified objects using the given QualifiedActor.
  List<R> actOnQualifiedSet<R>(CharID id, dynamic qa) {
    final list = <R>[];
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        final obj = entry.key;
        final sources = entry.value;
        for (final source in sources) {
          // stub: prereqFacet.qualifies(id, obj, source)
          if (_prereqFacet?.qualifies(id, obj, source) == true) {
            list.add(qa.act(obj, source) as R);
          }
        }
      }
    }
    return list;
  }

  /// Returns unmodifiable collection of sources for the given object.
  Iterable<Object?> getSources(CharID id, T obj) {
    final componentMap = _getCachedMap(id);
    if (componentMap != null) {
      final sources = componentMap[obj];
      if (sources != null) {
        return List.unmodifiable(sources.toList());
      }
    }
    return const [];
  }
}
