//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.facet.base.AbstractSubAssociationFacet
import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';

// Facet storing (S1, S2) → A associations per IDT (one association per (S1,S2) pair).
abstract class AbstractSubAssociationFacet<IDT extends PCGenIdentifier, S1, S2, A>
    extends AbstractStorageFacet<IDT> {

  Map<S1, Map<S2, A>>? _getCachedMap(IDT id) =>
      getCache(id) as Map<S1, Map<S2, A>>?;

  Map<S1, Map<S2, A>> _getConstructingMap(IDT id) {
    var map = _getCachedMap(id);
    if (map == null) {
      map = <S1, Map<S2, A>>{};
      setCache(id, map);
    }
    return map;
  }

  A? get(IDT id, S1 scope1, S2 scope2) =>
      _getCachedMap(id)?[scope1]?[scope2];

  void set(IDT id, S1 scope1, S2 scope2, A association) {
    _getConstructingMap(id).putIfAbsent(scope1, () => <S2, A>{})[scope2] =
        association;
  }

  void removeAssoc(IDT id, S1 scope1, S2 scope2) {
    final map = _getCachedMap(id);
    if (map == null) return;
    final s2Map = map[scope1];
    if (s2Map == null) return;
    s2Map.remove(scope2);
    if (s2Map.isEmpty) map.remove(scope1);
    if (map.isEmpty) removeCache(id);
  }

  bool contains(IDT id, S1 scope1, S2 scope2) =>
      _getCachedMap(id)?[scope1]?.containsKey(scope2) ?? false;

  List<S2> getScopes2(IDT id, S1 scope1) {
    final sub = _getCachedMap(id)?[scope1];
    return sub == null ? const [] : List.of(sub.keys);
  }

  @override
  void copyContents(IDT source, IDT destination) {
    final map = _getCachedMap(source);
    if (map != null) {
      final dest = _getConstructingMap(destination);
      for (final e in map.entries) {
        dest.putIfAbsent(e.key, () => <S2, A>{}).addAll(e.value);
      }
    }
  }
}
