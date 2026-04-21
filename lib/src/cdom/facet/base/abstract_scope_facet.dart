//
// Copyright (c) Thomas Parker, 2013.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.facet.base.AbstractScopeFacet
import '../../base/pcgen_identifier.dart';
import '../event/scope_facet_change_event.dart';
import '../event/scope_facet_change_listener.dart';
import 'abstract_storage_facet.dart';

// Facet keyed by (IDT, scope S) → objects T with multi-source tracking.
abstract class AbstractScopeFacet<IDT extends PCGenIdentifier, S, T>
    extends AbstractStorageFacet<IDT> {

  final Map<int, List<ScopeFacetChangeListener<IDT, S, T>>> _listeners = {};

  Map<S, Map<T, Set<Object>>>? _getInfo(IDT id) =>
      getCache(id) as Map<S, Map<T, Set<Object>>>?;

  Map<S, Map<T, Set<Object>>> _getConstructingInfo(IDT id) {
    var map = _getInfo(id);
    if (map == null) {
      map = <S, Map<T, Set<Object>>>{};
      setCache(id, map);
    }
    return map;
  }

  void add(IDT id, S scope, T obj, Object source) {
    final map = _getConstructingInfo(id);
    final scopeMap = map.putIfAbsent(scope, () => <T, Set<Object>>{});
    final isNew = !scopeMap.containsKey(obj);
    final sources = scopeMap.putIfAbsent(obj, () => <Object>{});
    sources.add(source);
    if (isNew) {
      fireScopeFacetChangeEvent(id, scope, obj, ScopeFacetChangeEvent.dataAdded);
    }
  }

  void addAll(IDT id, S scope, List<T> coll, Object source) {
    final map = _getConstructingInfo(id);
    final scopeMap = map.putIfAbsent(scope, () => <T, Set<Object>>{});
    for (final obj in coll) {
      final isNew = !scopeMap.containsKey(obj);
      final sources = scopeMap.putIfAbsent(obj, () => <Object>{});
      sources.add(source);
      if (isNew) {
        fireScopeFacetChangeEvent(id, scope, obj, ScopeFacetChangeEvent.dataAdded);
      }
    }
  }

  void remove(IDT id, S scope, T obj, Object source) {
    final map = _getInfo(id);
    if (map == null) return;
    final scopeMap = map[scope];
    if (scopeMap == null) return;
    final sources = scopeMap[obj];
    if (sources == null) return;
    if (sources.remove(source) && sources.isEmpty) {
      fireScopeFacetChangeEvent(id, scope, obj, ScopeFacetChangeEvent.dataRemoved);
      scopeMap.remove(obj);
    }
    if (scopeMap.isEmpty) map.remove(scope);
    if (map.isEmpty) removeCache(id);
  }

  List<T> getSet(IDT id, S scope) {
    final map = _getInfo(id);
    if (map == null) return const [];
    final scopeMap = map[scope];
    if (scopeMap == null) return const [];
    return List.of(scopeMap.keys);
  }

  List<S> getScopes(IDT id) {
    final map = _getInfo(id);
    if (map == null) return const [];
    return List.of(map.keys);
  }

  bool contains(IDT id, S scope, T obj) {
    final map = _getInfo(id);
    if (map == null) return false;
    return map[scope]?.containsKey(obj) ?? false;
  }

  void removeAllFromSource(IDT id, Object source) {
    final map = _getInfo(id);
    if (map == null) return;
    final toFire = <MapEntry<S, T>>[];
    for (final se in map.entries.toList()) {
      final scopeMap = se.value;
      for (final oe in scopeMap.entries.toList()) {
        final sources = oe.value;
        if (sources.remove(source) && sources.isEmpty) {
          scopeMap.remove(oe.key);
          toFire.add(MapEntry(se.key, oe.key));
        }
      }
      if (scopeMap.isEmpty) map.remove(se.key);
    }
    if (map.isEmpty) removeCache(id);
    for (final e in toFire) {
      fireScopeFacetChangeEvent(id, e.key, e.value, ScopeFacetChangeEvent.dataRemoved);
    }
  }

  @override
  void copyContents(IDT source, IDT copy) {
    final map = _getInfo(source);
    if (map != null) {
      for (final se in map.entries) {
        for (final oe in se.value.entries) {
          for (final src in oe.value) {
            add(copy, se.key, oe.key, src);
          }
        }
      }
    }
  }

  void addScopeFacetChangeListener(ScopeFacetChangeListener<IDT, S, T> listener,
      [int priority = 0]) {
    _listeners.putIfAbsent(priority, () => []).insert(0, listener);
  }

  void removeScopeFacetChangeListener(ScopeFacetChangeListener<IDT, S, T> listener,
      [int priority = 0]) {
    _listeners[priority]?.remove(listener);
  }

  void fireScopeFacetChangeEvent(IDT id, S scope, T node, int type) {
    final sortedKeys = _listeners.keys.toList()..sort();
    for (final key in sortedKeys) {
      final list = _listeners[key]!;
      final event = ScopeFacetChangeEvent<IDT, S, T>(id, scope, node, this, type);
      for (int i = list.length - 1; i >= 0; i--) {
        if (type == ScopeFacetChangeEvent.dataAdded) {
          list[i].dataAdded(event);
        } else {
          list[i].dataRemoved(event);
        }
      }
    }
  }
}
