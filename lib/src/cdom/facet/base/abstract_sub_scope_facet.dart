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
// Translation of pcgen.cdom.facet.base.AbstractSubScopeFacet
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/sub_scope_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/sub_scope_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';

// Facet keyed by (CharID, S1, S2) → objects T with multi-source tracking.
abstract class AbstractSubScopeFacet<S1, S2, T>
    extends AbstractStorageFacet<CharID> {

  final Map<int, List<SubScopeFacetChangeListener<S1, S2, T>>> _listeners = {};

  Map<S1, Map<S2, Map<T, Set<Object>>>>? _getInfo(CharID id) =>
      getCache(id) as Map<S1, Map<S2, Map<T, Set<Object>>>>?;

  Map<S1, Map<S2, Map<T, Set<Object>>>> _getConstructingInfo(CharID id) {
    var map = _getInfo(id);
    if (map == null) {
      map = <S1, Map<S2, Map<T, Set<Object>>>>{};
      setCache(id, map);
    }
    return map;
  }

  void add(CharID id, S1 scope1, S2 scope2, T obj, Object source) {
    final map = _getConstructingInfo(id);
    final s1Map = map.putIfAbsent(scope1, () => <S2, Map<T, Set<Object>>>{});
    final s2Map = s1Map.putIfAbsent(scope2, () => <T, Set<Object>>{});
    final isNew = !s2Map.containsKey(obj);
    s2Map.putIfAbsent(obj, () => <Object>{}).add(source);
    if (isNew) {
      _fireEvent(id, scope1, scope2, obj, SubScopeFacetChangeEvent.dataAdded);
    }
  }

  void remove(CharID id, S1 scope1, S2 scope2, T obj, Object source) {
    final map = _getInfo(id);
    if (map == null) return;
    final s1Map = map[scope1];
    if (s1Map == null) return;
    final s2Map = s1Map[scope2];
    if (s2Map == null) return;
    final sources = s2Map[obj];
    if (sources == null) return;
    if (sources.remove(source) && sources.isEmpty) {
      _fireEvent(id, scope1, scope2, obj, SubScopeFacetChangeEvent.dataRemoved);
      s2Map.remove(obj);
    }
    if (s2Map.isEmpty) s1Map.remove(scope2);
    if (s1Map.isEmpty) map.remove(scope1);
    if (map.isEmpty) removeCache(id);
  }

  List<T> getSet(CharID id, S1 scope1, S2 scope2) {
    final map = _getInfo(id);
    if (map == null) return const [];
    final s2Map = map[scope1]?[scope2];
    if (s2Map == null) return const [];
    return List.of(s2Map.keys);
  }

  int getSize(CharID id, S1 scope1, S2 scope2) =>
      _getInfo(id)?[scope1]?[scope2]?.length ?? 0;

  bool contains(CharID id, S1 scope1, S2 scope2, T obj) =>
      _getInfo(id)?[scope1]?[scope2]?.containsKey(obj) ?? false;

  List<S1> getScopes1(CharID id) {
    final map = _getInfo(id);
    return map == null ? const [] : List.of(map.keys);
  }

  List<S2> getScopes2(CharID id, S1 scope1) {
    final sub = _getInfo(id)?[scope1];
    return sub == null ? const [] : List.of(sub.keys);
  }

  bool containsFor(CharID id, S1 scope1) =>
      _getInfo(id)?.containsKey(scope1) ?? false;

  void removeAllFromSource(CharID id, Object source) {
    final map = _getInfo(id);
    if (map == null) return;
    for (final s1e in map.entries.toList()) {
      for (final s2e in s1e.value.entries.toList()) {
        for (final oe in s2e.value.entries.toList()) {
          final sources = oe.value;
          if (sources.remove(source) && sources.isEmpty) {
            s2e.value.remove(oe.key);
            _fireEvent(id, s1e.key, s2e.key, oe.key,
                SubScopeFacetChangeEvent.dataRemoved);
          }
        }
        if (s2e.value.isEmpty) s1e.value.remove(s2e.key);
      }
      if (s1e.value.isEmpty) map.remove(s1e.key);
    }
    if (map.isEmpty) removeCache(id);
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getInfo(source);
    if (map != null) {
      for (final s1e in map.entries) {
        for (final s2e in s1e.value.entries) {
          for (final oe in s2e.value.entries) {
            for (final src in oe.value) {
              add(copy, s1e.key, s2e.key, oe.key, src);
            }
          }
        }
      }
    }
  }

  void addSubScopeFacetChangeListener(
      SubScopeFacetChangeListener<S1, S2, T> listener,
      [int priority = 0]) {
    _listeners.putIfAbsent(priority, () => []).insert(0, listener);
  }

  void removeSubScopeFacetChangeListener(
      SubScopeFacetChangeListener<S1, S2, T> listener,
      [int priority = 0]) {
    _listeners[priority]?.remove(listener);
  }

  void _fireEvent(CharID id, S1 scope1, S2 scope2, T node, int type) {
    final sortedKeys = _listeners.keys.toList()..sort();
    for (final key in sortedKeys) {
      final list = _listeners[key]!;
      final event =
          SubScopeFacetChangeEvent<S1, S2, T>(id, scope1, scope2, node, this, type);
      for (int i = list.length - 1; i >= 0; i--) {
        if (type == SubScopeFacetChangeEvent.dataAdded) {
          list[i].dataAdded(event);
        } else {
          list[i].dataRemoved(event);
        }
      }
    }
  }
}
