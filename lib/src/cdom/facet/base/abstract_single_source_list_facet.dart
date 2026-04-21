// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'abstract_data_facet.dart';

/// An AbstractSingleSourceListFacet is a DataFacet that contains information
/// about Objects where each Object may have only one source.
///
/// If the object is re-added with a second source, the source is updated without
/// triggering a new DATA_ADDED event.
///
/// null is NOT a valid source.
abstract class AbstractSingleSourceListFacet<T, ST>
    extends AbstractDataFacet<CharID, T> {
  /// Adds the given object with the given source.
  void add(CharID id, T obj, ST source) {
    final map = _getConstructingCachedMap(id);
    final oldSource = map[obj];
    final fireNew = oldSource == null;
    map[obj] = source;
    if (fireNew) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
    }
  }

  /// Adds all objects in [c] with the given source.
  void addAll(CharID id, Iterable<T> c, ST source) {
    for (final obj in c) {
      add(id, obj, source);
    }
  }

  /// Removes the given source entry for the given object.
  /// Only removes if the given source matches the stored source.
  void remove(CharID id, T obj, ST source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      _processRemoval(id, componentMap, obj, source);
    }
  }

  /// Removes the given source from all objects in [c].
  void removeAll(CharID id, Iterable<T> c, ST source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final obj in c) {
        _processRemoval(id, componentMap, obj, source);
      }
    }
  }

  /// Removes all objects (and their sources) for the given id.
  /// Returns the old map.
  Map<T, ST> removeAllObjects(CharID id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return {};
    removeCache(id);
    for (final obj in componentMap.keys.toList()) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
    }
    return componentMap;
  }

  /// Returns an unmodifiable set of all objects for the given id.
  Set<T> getSet(CharID id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return <T>{};
    return Set.unmodifiable(componentMap.keys.toSet());
  }

  /// Returns the count of items for the given id.
  int getCount(CharID id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return 0;
    return componentMap.length;
  }

  /// Returns true if no items exist for the given id.
  bool isEmpty(CharID id) {
    final componentMap = getCachedMap(id);
    return componentMap == null || componentMap.isEmpty;
  }

  /// Returns true if this facet contains the given object for the given id.
  bool contains(CharID id, T obj) {
    final componentMap = getCachedMap(id);
    return componentMap != null && componentMap.containsKey(obj);
  }

  /// Returns the cached map (may be null).
  Map<T, ST>? getCachedMap(CharID id) {
    return getCache(id) as Map<T, ST>?;
  }

  Map<T, ST> _getConstructingCachedMap(CharID id) {
    Map<T, ST>? componentMap = getCachedMap(id);
    if (componentMap == null) {
      componentMap = getComponentMap();
      setCache(id, componentMap);
    }
    return componentMap;
  }

  /// Returns a new empty Map for storage. Override for custom map types.
  Map<T, ST> getComponentMap() {
    return <T, ST>{};
  }

  @override
  void copyContents(CharID source, CharID destination) {
    final sourceMap = getCachedMap(source);
    if (sourceMap != null) {
      _getConstructingCachedMap(destination).addAll(sourceMap);
    }
  }

  void _processRemoval(
      CharID id, Map<T, ST> componentMap, T obj, ST source) {
    final oldSource = componentMap[obj];
    if (oldSource != null) {
      if (oldSource == source) {
        componentMap.remove(obj);
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      }
    }
  }

  /// Removes all information for the given source for the given id.
  void removeAllFromSource(CharID id, ST source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      final removedKeys = <T>[];
      for (final entry in componentMap.entries.toList()) {
        if (entry.value == source) {
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
  List<T> getSetForOwner(CharID id, ST owner) {
    final list = <T>[];
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        if (entry.value == owner) {
          list.add(entry.key);
        }
      }
    }
    return List.unmodifiable(list);
  }

  /// Returns the source for the given object, or null if not present.
  ST? getSource(CharID id, T obj) {
    final map = getCachedMap(id);
    if (map == null) return null;
    return map[obj];
  }

  /// Removes the given object unconditionally (regardless of source).
  void removeObject(CharID id, T obj) {
    final map = getCachedMap(id);
    if (map != null) {
      if (map.remove(obj) != null) {
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
      }
    }
  }
}
