//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.primitive.CompoundOrPrimitive
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'primitive_utilities.dart';

// PrimitiveCollection that returns the union of multiple sub-collections.
class CompoundOrPrimitive<T> {
  final Type? _refClass;
  final List<dynamic> _primCollection; // sorted by LST format

  CompoundOrPrimitive(List<dynamic> pcfCollection)
      : _primCollection = List.from(pcfCollection)
          ..sort(PrimitiveUtilities.collectionSorter),
        _refClass = pcfCollection.isEmpty
            ? null
            : pcfCollection.first.getReferenceClass() as Type {
    if (pcfCollection.isEmpty) {
      throw ArgumentError('Collection for CompoundOrPrimitive cannot be empty');
    }
  }

  Set<dynamic> getCollection(PlayerCharacter pc, dynamic c) {
    final returnSet = <dynamic>{};
    for (final cs in _primCollection) {
      returnSet.addAll(cs.getCollection(pc, c) as Iterable);
    }
    return returnSet;
  }

  Type? getReferenceClass() => _refClass;

  GroupingState getGroupingState() {
    var state = GroupingState.empty;
    for (final pcs in _primCollection) {
      state = (pcs.getGroupingState() as GroupingState).add(state);
    }
    return state.compound(GroupingState.allowsUnion);
  }

  String getLSTformat([bool useAny = false]) =>
      PrimitiveUtilities.joinLstFormat(_primCollection, '|', useAny);

  @override
  int get hashCode => _primCollection.fold(0, (h, e) => h ^ e.hashCode);

  @override
  bool operator ==(Object obj) =>
      obj is CompoundOrPrimitive &&
      _listEquals(obj._primCollection, _primCollection);

  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
