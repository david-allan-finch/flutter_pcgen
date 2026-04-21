// Copyright (c) Thomas Parker, 2010-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';

/// Storage class for AbstractItemConvertingFacet: holds the converted destination
/// object and the set of sources.
class ConvertingTarget<D> {
  /// The set of source objects (identity-based).
  final Set<Object?> set = <Object?>{};

  /// The converted ("destination") object.
  D? dest;

  @override
  int get hashCode => dest.hashCode;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is ConvertingTarget<D>) {
      return dest == o.dest && set == o.set;
    }
    return false;
  }
}

/// An AbstractItemConvertingFacet is a DataFacet that converts information from
/// one type to another when the source of that object should be tracked.
///
/// Each original object may only be contained one time by the PlayerCharacter,
/// even if received from multiple sources.
abstract class AbstractItemConvertingFacet<S, D>
    extends AbstractDataFacet<CharID, D> {
  /// Adds the converted version of the given object with the given source.
  void add(CharID id, S obj, Object? source) {
    final target = _getConstructingCachedSetFor(id, obj);
    target.set.add(source);
    if (target.dest == null) {
      target.dest = convert(obj);
      fireDataFacetChangeEvent(id, target.dest as D, DataFacetChangeEvent.dataAdded);
    }
  }

  /// Adds conversions of all objects in [c] with the given source.
  void addAll(CharID id, Iterable<S> c, Object? source) {
    for (final obj in c) {
      add(id, obj, source);
    }
  }

  /// Removes the given source for the given object.
  void remove(CharID id, S obj, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      _processRemoval(id, componentMap, obj, source);
    }
  }

  /// Removes the given source from all objects in [c].
  void removeAll(CharID id, Iterable<S> c, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final obj in c) {
        _processRemoval(id, componentMap, obj, source);
      }
    }
  }

  /// Removes all converted objects (and all sources) for the given id.
  /// Returns the old map.
  Map<S, ConvertingTarget<D>> removeAllObjects(CharID id) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return {};
    removeCache(id);
    for (final tgt in componentMap.values) {
      if (tgt.dest != null) {
        fireDataFacetChangeEvent(id, tgt.dest as D, DataFacetChangeEvent.dataRemoved);
      }
    }
    return componentMap;
  }

  /// Returns the count of original objects for the given id.
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

  /// Returns true if the given source object was provided and converted.
  bool contains(CharID id, S obj) {
    final componentMap = getCachedMap(id);
    return componentMap != null && componentMap.containsKey(obj);
  }

  ConvertingTarget<D> _getConstructingCachedSetFor(CharID id, S obj) {
    final map = _getConstructingCachedMap(id);
    return map.putIfAbsent(obj, () => ConvertingTarget<D>());
  }

  Map<S, ConvertingTarget<D>>? getCachedMap(CharID id) {
    return getCache(id) as Map<S, ConvertingTarget<D>>?;
  }

  Map<S, ConvertingTarget<D>> _getConstructingCachedMap(CharID id) {
    Map<S, ConvertingTarget<D>>? componentMap = getCachedMap(id);
    if (componentMap == null) {
      componentMap = getComponentMap();
      setCache(id, componentMap);
    }
    return componentMap;
  }

  /// Returns a new empty Map for storage. Override for custom map types.
  Map<S, ConvertingTarget<D>> getComponentMap() {
    return <S, ConvertingTarget<D>>{};
  }

  @override
  void copyContents(CharID source, CharID destination) {
    final sourceMap = getCachedMap(source);
    if (sourceMap != null) {
      for (final entry in sourceMap.entries) {
        final origTarget = entry.value;
        final target = _getConstructingCachedSetFor(destination, entry.key);
        target.dest = origTarget.dest; // could be dangerous (shared reference)
        target.set.addAll(origTarget.set);
      }
    }
  }

  void _processRemoval(
      CharID id, Map<S, ConvertingTarget<D>> componentMap, S obj, Object? source) {
    final target = componentMap[obj];
    if (target != null) {
      target.set.remove(source);
      if (target.set.isEmpty) {
        componentMap.remove(obj);
        if (target.dest != null) {
          fireDataFacetChangeEvent(id, target.dest as D, DataFacetChangeEvent.dataRemoved);
        }
      }
    }
  }

  /// Removes all information for the given source from this facet.
  void removeAllFromSource(CharID id, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      final toRemove = <S, ConvertingTarget<D>>{};
      for (final entry in componentMap.entries) {
        final target = entry.value;
        if (target.set.remove(source) && target.set.isEmpty) {
          toRemove[entry.key] = target;
        }
      }
      for (final key in toRemove.keys) {
        componentMap.remove(key);
        final tgt = toRemove[key]!;
        if (tgt.dest != null) {
          fireDataFacetChangeEvent(id, tgt.dest as D, DataFacetChangeEvent.dataRemoved);
        }
      }
    }
  }

  /// Returns true if an object from the given source exists for the given id.
  bool containsFrom(CharID id, Object? source) {
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      for (final target in componentMap.values) {
        if (target.set.contains(source)) return true;
      }
    }
    return false;
  }

  /// Converts the given source object to a destination object.
  D convert(S obj);

  /// Returns all source objects for the given id.
  Set<S> getSourceObjects(CharID id) {
    final set = <S>{};
    final componentMap = getCachedMap(id);
    if (componentMap != null) {
      set.addAll(componentMap.keys);
    }
    return set;
  }

  /// Returns the converted result for the given source object.
  D? getResultFor(CharID id, S obj) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return null;
    return componentMap[obj]?.dest;
  }

  /// Returns all sources for the given source object.
  Set<Object?> getSourcesFor(CharID id, S obj) {
    final componentMap = getCachedMap(id);
    final set = <Object?>{};
    if (componentMap == null) return set;
    final target = componentMap[obj];
    if (target != null) set.addAll(target.set);
    return set;
  }
}
