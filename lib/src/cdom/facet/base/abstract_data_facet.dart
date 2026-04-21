// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'abstract_storage_facet.dart';

// dynamic: CategorizedDataFacetChangeEvent, Category, Nature (not yet translated)

/// A AbstractDataFacet is a DataFacet that contains information about
/// CDOMObjects that are contained in a resource. This serves the basic functions
/// of managing the DataFacetChangeListeners for a DataFacet.
///
/// DataFacetChangeListeners registered with lower priority (more negative)
/// receive events first.
abstract class AbstractDataFacet<IDT extends PCGenIdentifier, T>
    extends AbstractStorageFacet<IDT> {
  /// Priority-ordered map of listener arrays. Lower key = earlier notification.
  final Map<int, List<DataFacetChangeListener<IDT, T>>> _listeners = {};

  /// Adds a DataFacetChangeListener at default priority (0).
  void addDataFacetChangeListener(DataFacetChangeListener<IDT, T> listener) {
    addDataFacetChangeListenerWithPriority(0, listener);
  }

  /// Adds a DataFacetChangeListener at the given priority.
  void addDataFacetChangeListenerWithPriority(
      int priority, DataFacetChangeListener<IDT, T> listener) {
    _listeners.putIfAbsent(priority, () => []).insert(0, listener);
  }

  /// Removes a DataFacetChangeListener from default priority (0).
  void removeDataFacetChangeListener(DataFacetChangeListener<IDT, T> listener) {
    removeDataFacetChangeListenerWithPriority(0, listener);
  }

  /// Removes a DataFacetChangeListener from the given priority.
  void removeDataFacetChangeListenerWithPriority(
      int priority, DataFacetChangeListener<IDT, T> listener) {
    final list = _listeners[priority];
    if (list == null) return;
    // Remove last occurrence (search from end)
    for (int i = list.length - 1; i >= 0; i--) {
      if (identical(list[i], listener)) {
        list.removeAt(i);
        break;
      }
    }
    if (list.isEmpty) {
      _listeners.remove(priority);
    }
  }

  /// Sends a DataFacetChangeEvent to all registered listeners.
  void fireDataFacetChangeEvent(IDT id, T node, int type) {
    _fireDataFacetChangeEventFull(id, node, type, null, null);
  }

  /// Sends a DataFacetChangeEvent with category/nature to all registered listeners.
  void _fireDataFacetChangeEventFull(
      IDT id, T node, int type, dynamic category, dynamic nature) {
    final sortedKeys = _listeners.keys.toList()..sort();
    for (final priority in sortedKeys) {
      final listenerList = _listeners[priority]!;
      DataFacetChangeEvent<IDT, T>? ccEvent;
      // Iterate in reverse (last added = first notified within same priority)
      for (int i = listenerList.length - 1; i >= 0; i--) {
        ccEvent ??= (category == null)
            ? DataFacetChangeEvent<IDT, T>(id, node, this, type)
            : DataFacetChangeEvent<IDT, T>.categorized(
                id, node, this, type, category, nature); // stub categorized
        final dfcl = listenerList[i];
        switch (ccEvent.eventType) {
          case DataFacetChangeEvent.dataAdded:
            dfcl.dataAdded(ccEvent);
            break;
          case DataFacetChangeEvent.dataRemoved:
            dfcl.dataRemoved(ccEvent);
            break;
        }
      }
    }
  }

  /// Returns all currently registered DataFacetChangeListeners across all priorities.
  List<DataFacetChangeListener<IDT, T>> getDataFacetChangeListeners() {
    final result = <DataFacetChangeListener<IDT, T>>[];
    final sortedKeys = _listeners.keys.toList()..sort();
    for (final priority in sortedKeys) {
      result.addAll(_listeners[priority]!);
    }
    return result;
  }
}
