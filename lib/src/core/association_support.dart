//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.AssociationSupport
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_list_key.dart';

// Stores per-object associations keyed by AssociationKey / AssociationListKey.
// Uses identity semantics for the primary key (matches Java IdentityHashMap).
class AssociationSupport {
  // assocMTL: obj -> AssociationListKey -> List
  final Map<Object, Map<Object, List<dynamic>>> _assocMTL = {};
  // assocMap: obj -> AssociationKey -> value
  final Map<Object, Map<Object, dynamic>> _assocMap = {};

  void addAssoc<T>(Object obj, AssociationListKey<T> ak, T o) {
    _assocMTL.putIfAbsent(obj, () => {})[ak] ??= [];
    (_assocMTL[obj]![ak] as List).add(o);
  }

  void removeAssoc<T>(Object obj, AssociationListKey<T> ak, T o) {
    (_assocMTL[obj]?[ak] as List?)?.remove(o);
  }

  List<T>? removeAllAssocs<T>(Object obj, AssociationListKey<T> ak) {
    final inner = _assocMTL[obj];
    if (inner == null) return null;
    final list = inner.remove(ak) as List<T>?;
    return list;
  }

  int getAssocCount(Object obj, AssociationListKey<dynamic> ak) {
    return (_assocMTL[obj]?[ak] as List?)?.length ?? 0;
  }

  bool hasAssocsList(Object obj, AssociationListKey<dynamic> ak) {
    final list = _assocMTL[obj]?[ak] as List?;
    return list != null && list.isNotEmpty;
  }

  List<T>? getAssocList<T>(Object obj, AssociationListKey<T> ak) {
    final raw = _assocMTL[obj]?[ak];
    return raw == null ? null : List<T>.from(raw as List);
  }

  bool containsAssoc<T>(Object obj, AssociationListKey<T> ak, T o) {
    return (_assocMTL[obj]?[ak] as List?)?.contains(o) ?? false;
  }

  void setAssoc<T>(Object obj, AssociationKey<T> ak, T o) {
    _assocMap.putIfAbsent(obj, () => {})[ak] = o;
  }

  void removeAssocKey<T>(Object obj, AssociationKey<T> ak) {
    _assocMap[obj]?.remove(ak);
  }

  bool hasAssocs<T>(Object obj, AssociationKey<T> ak) {
    return _assocMap[obj]?.containsKey(ak) ?? false;
  }

  T? getAssoc<T>(Object obj, AssociationKey<T> ak) {
    return _assocMap[obj]?[ak] as T?;
  }

  void convertAssociations(Object oldTarget, Object newTarget) {
    final mapInner = _assocMap.remove(oldTarget);
    if (mapInner != null) {
      _assocMap.putIfAbsent(newTarget, () => {}).addAll(mapInner);
    }
    final listInner = _assocMTL.remove(oldTarget);
    if (listInner != null) {
      final dest = _assocMTL.putIfAbsent(newTarget, () => {});
      for (final entry in listInner.entries) {
        (dest[entry.key] as List? ?? (dest[entry.key] = []))
            .addAll(entry.value);
      }
    }
  }

  bool containsAssocList(Object o, AssociationListKey<dynamic> alk) {
    return hasAssocsList(o, alk);
  }

  void sortAssocList<T extends Comparable<T>>(
      Object obj, AssociationListKey<T> ak) {
    final raw = _assocMTL[obj]?[ak] as List?;
    if (raw != null) {
      raw.sort((a, b) => (a as Comparable).compareTo(b));
    }
  }

  AssociationSupport clone() {
    final result = AssociationSupport();
    for (final e in _assocMTL.entries) {
      result._assocMTL[e.key] = {
        for (final ie in e.value.entries)
          ie.key: List.from(ie.value as List)
      };
    }
    for (final e in _assocMap.entries) {
      result._assocMap[e.key] = Map.from(e.value);
    }
    return result;
  }
}
