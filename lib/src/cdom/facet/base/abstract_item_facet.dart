// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../base/pc_gen_identifier.dart';
import '../event/data_facet_change_event.dart';
import 'abstract_data_facet.dart';

/// An AbstractItemFacet is a DataFacet that contains information about Objects
/// that are contained in a PlayerCharacter when a PlayerCharacter may have only
/// one of that type of Object (e.g. Race, Deity).
abstract class AbstractItemFacet<IDT extends PCGenIdentifier, T>
    extends AbstractDataFacet<IDT, T> {
  /// Sets the item for this facet. Ignores null values (logs error).
  /// Returns true if the item was set; false otherwise.
  bool set(IDT id, T obj) {
    // ignore null: Dart generics prevent null unless T is nullable
    final T? old = get(id);
    if (identical(old, obj)) {
      return false;
    } else {
      if (old != null) {
        fireDataFacetChangeEvent(id, old, DataFacetChangeEvent.dataRemoved);
      }
      setCache(id, obj);
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
      return true;
    }
  }

  /// Removes the item for this facet. Returns the old value or null.
  T? remove(IDT id) {
    final T? old = removeCache(id) as T?;
    if (old != null) {
      fireDataFacetChangeEvent(id, old, DataFacetChangeEvent.dataRemoved);
    }
    return old;
  }

  /// Returns the current item for the given id. May be null if not set.
  T? get(IDT id) {
    return getCache(id) as T?;
  }

  /// Returns true if the item for the given id matches the given value.
  /// null may be used to test that no value is set.
  bool matches(IDT id, T? obj) {
    final T? current = get(id);
    return (obj == null && current == null) ||
        (obj != null && obj == current);
  }

  @override
  void copyContents(IDT source, IDT copy) {
    final T? obj = get(source);
    if (obj != null) {
      setCache(copy, obj);
    }
  }
}
