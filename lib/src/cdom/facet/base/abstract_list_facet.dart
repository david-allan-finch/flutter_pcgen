// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'abstract_data_facet.dart';

/// A AbstractListFacet is a DataFacet that contains information about Objects
/// that are contained in a Player Character when a Player Character may have
/// more than one of that type of Object (e.g. Language, PCTemplate).
///
/// The source of the Objects does not need to be tracked.
/// null is not a valid object to be stored.
abstract class AbstractListFacet<IDT extends PCGenIdentifier, T>
    extends AbstractDataFacet<IDT, T> {
  /// Adds the given object to the list for the given id.
  /// Returns true if added; false if already present.
  bool add(IDT id, T obj) {
    final set = _getConstructingCachedSet(id);
    if (set.add(obj)) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
      return true;
    }
    return false;
  }

  /// Adds all objects in the given collection for the given id.
  void addAll(IDT id, Iterable<T> c) {
    final list = c.toList();
    if (list.isEmpty) return;
    final set = _getConstructingCachedSet(id);
    for (final obj in list) {
      if (set.add(obj)) {
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
      }
    }
  }

  /// Removes the given object from the list for the given id.
  /// Returns true if removed.
  bool remove(IDT id, T obj) {
    final componentSet = getCachedSet(id);
    if (componentSet != null) {
      if (componentSet.remove(obj)) {
        fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
        if (componentSet.isEmpty) {
          removeCache(id);
        }
        return true;
      }
    }
    return false;
  }

  /// Removes all objects in the given collection from the list for the given id.
  void removeCollection(IDT id, Iterable<T> c) {
    final componentSet = getCachedSet(id);
    if (componentSet != null) {
      for (final obj in c) {
        if (componentSet.remove(obj)) {
          fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
        }
      }
    }
  }

  /// Removes all objects from the list for the given id.
  /// Returns the removed objects.
  Set<T> removeAll(IDT id) {
    final componentSet = removeCache(id) as Set<T>?;
    if (componentSet == null) return <T>{};
    for (final obj in componentSet) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
    }
    return componentSet;
  }

  /// Returns an unmodifiable copy of the set for the given id.
  List<T> getSet(IDT id) {
    final componentSet = getCachedSet(id);
    if (componentSet == null) return const [];
    return List.unmodifiable(componentSet.toList());
  }

  /// Returns the count of items for the given id.
  int getCount(IDT id) {
    final componentSet = getCachedSet(id);
    if (componentSet == null) return 0;
    return componentSet.length;
  }

  /// Returns true if this facet has no items for the given id.
  bool isEmpty(IDT id) {
    final componentSet = getCachedSet(id);
    return componentSet == null || componentSet.isEmpty;
  }

  /// Returns true if this facet contains the given object for the given id.
  bool contains(IDT id, T obj) {
    final componentSet = getCachedSet(id);
    return componentSet != null && componentSet.contains(obj);
  }

  /// Returns the internal cached set (may be null). Not public.
  Set<T>? getCachedSet(IDT id) {
    return getCache(id) as Set<T>?;
  }

  Set<T> _getConstructingCachedSet(IDT id) {
    Set<T>? componentSet = getCachedSet(id);
    if (componentSet == null) {
      componentSet = getComponentSet();
      setCache(id, componentSet);
    }
    return componentSet;
  }

  /// Returns a new empty Set for storage. Override for custom collection types.
  Set<T> getComponentSet() {
    return <T>{};
  }

  @override
  void copyContents(IDT source, IDT copy) {
    final componentSet = getCachedSet(source);
    if (componentSet != null) {
      _getConstructingCachedSet(copy).addAll(getCopyForNewOwner(componentSet));
    }
  }

  /// Returns a collection of data ready to be saved for a new character.
  /// Override for deep-cloning.
  Set<T> getCopyForNewOwner(Set<T> componentSet) {
    return componentSet;
  }

  /// Replaces [old] with [replacement] in the collection for the given id.
  /// Returns true if the replacement was made.
  bool replace(IDT id, T old, T replacement) {
    final componentSet = getCachedSet(id);
    if (componentSet == null || !componentSet.contains(old)) return false;
    final replaceSet = getComponentSet();
    for (final obj in componentSet) {
      if (identical(obj, old)) {
        replaceSet.add(replacement);
      } else {
        replaceSet.add(obj);
      }
    }
    setCache(id, replaceSet);
    fireDataFacetChangeEvent(id, old, DataFacetChangeEvent.dataRemoved);
    fireDataFacetChangeEvent(id, replacement, DataFacetChangeEvent.dataAdded);
    return true;
  }

  /// Adds [added] directly after [trigger] in the ordered collection for the given id.
  /// If the underlying Set is unordered this is equivalent to add().
  void addAfter(IDT id, T trigger, T added) {
    final componentSet = getCachedSet(id);
    if (componentSet != null && componentSet.contains(trigger)) {
      final replaceSet = getComponentSet();
      for (final obj in componentSet) {
        replaceSet.add(obj);
        if (identical(obj, trigger)) {
          replaceSet.add(added);
        }
      }
      setCache(id, replaceSet);
      fireDataFacetChangeEvent(id, added, DataFacetChangeEvent.dataAdded);
    }
  }
}
