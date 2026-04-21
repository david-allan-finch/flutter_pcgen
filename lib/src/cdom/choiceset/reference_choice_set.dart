//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.ReferenceChoiceSet
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// A PrimitiveChoiceSet whose contents are defined by a collection of
// CDOMReferences. The contents are fixed and do not vary by PlayerCharacter.
class ReferenceChoiceSet<T> {
  // The underlying collection of CDOMReferences.
  final List<CDOMReference<T>> _refCollection;

  ReferenceChoiceSet(List<CDOMReference<T>> col) : _refCollection = [] {
    if (col.isEmpty) {
      throw ArgumentError('Choice Collection cannot be empty');
    }
    _refCollection.addAll(col);
  }

  String getLSTformat([bool useAny = false]) {
    // Sort by reference LST format for determinism.
    final sorted = List<CDOMReference<T>>.from(_refCollection)
      ..sort((a, b) {
        // stub: ReferenceUtilities.REFERENCE_SORTER
        return a.getLSTformat(false).compareTo(b.getLSTformat(false)); // stub
      });
    return _joinLstFormat(sorted, Constants.comma, useAny);
  }

  // stub: inline join since ReferenceUtilities not yet translated
  String _joinLstFormat(
    List<CDOMReference<T>> refs,
    String separator,
    bool useAny,
  ) {
    final parts = refs.map((r) => r.getLSTformat(useAny));
    return parts.join(separator);
  }

  Type getChoiceClass() {
    return _refCollection.isEmpty
        ? dynamic
        : _refCollection.first.getReferenceClass();
  }

  // Returns a set containing all objects from all references.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final CDOMReference<T> ref in _refCollection) {
      returnSet.addAll(ref.getContainedObjects());
    }
    return returnSet;
  }

  @override
  int get hashCode => _refCollection.length;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is ReferenceChoiceSet<T>) {
      if (_refCollection.length != obj._refCollection.length) return false;
      for (int i = 0; i < _refCollection.length; i++) {
        if (_refCollection[i] != obj._refCollection[i]) return false;
      }
      return true;
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final CDOMReference<T> ref in _refCollection) {
      state = ref.getGroupingState().add(state);
    }
    return state.compound(GroupingState.allowsUnion);
  }
}
