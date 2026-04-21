//
// Copyright 2006 (C) Tom Parker <thpr@sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.CompoundOrChoiceSet
import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/choiceset/choice_set_utilities.dart';

// A PrimitiveChoiceSet that performs a logical OR (union) of multiple
// underlying choice sets: objects present in ANY set are included.
class CompoundOrChoiceSet<T> {
  // Sorted set of underlying choice sets (sorted by LST format for determinism).
  final List<dynamic> _pcsSet = [];
  final String _separator;

  CompoundOrChoiceSet(List<dynamic> pcsCollection)
      : this.withSeparator(pcsCollection, Constants.pipe);

  CompoundOrChoiceSet.withSeparator(List<dynamic> pcsCollection, String sep)
      : _separator = sep {
    if (pcsCollection.isEmpty) {
      throw ArgumentError('Collection cannot be empty');
    }
    // Sort by LST format; detect duplicates.
    final sorted = List<dynamic>.from(pcsCollection)
      ..sort(ChoiceSetUtilities.compareChoiceSets);
    _pcsSet.addAll(sorted);
    if (_pcsSet.length != pcsCollection.length) {
      // stub: log duplicate warning
      // Logging.log(Level.WARNING, "Found duplicate item in $pcsCollection");
    }
  }

  // Returns the union of all underlying sets for the given PlayerCharacter.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final dynamic cs in _pcsSet) {
      returnSet.addAll((cs.getSet(pc) as Iterable).cast<T>());
    }
    return returnSet;
  }

  String getLSTformat([bool useAny = false]) {
    return ChoiceSetUtilities.joinLstFormat(_pcsSet, _separator, useAny);
  }

  Type getChoiceClass() {
    return (_pcsSet.first.getChoiceClass()) as Type;
  }

  @override
  int get hashCode => _pcsSet.fold(0, (h, e) => h ^ e.hashCode);

  @override
  bool operator ==(Object obj) {
    if (obj is CompoundOrChoiceSet) {
      if (_pcsSet.length != obj._pcsSet.length) return false;
      for (int i = 0; i < _pcsSet.length; i++) {
        if (_pcsSet[i] != obj._pcsSet[i]) return false;
      }
      return true;
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final dynamic pcs in _pcsSet) {
      state = (pcs.getGroupingState() as GroupingState).add(state);
    }
    return state.compound(GroupingState.allowsUnion);
  }
}
