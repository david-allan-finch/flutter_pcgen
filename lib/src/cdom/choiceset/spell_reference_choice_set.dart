//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.SpellReferenceChoiceSet
import '../base/cdom_list_object.dart';
import '../base/cdom_reference.dart';
import '../base/constants.dart';
import '../enumeration/grouping_state.dart';
import '../list/domain_spell_list.dart';

// A PrimitiveChoiceSet for CDOMListObject<Spell> objects, built from a
// collection of CDOMReferences to spell lists. DomainSpellList references are
// prefixed with "DOMAIN." in LST output to distinguish them from
// ClassSpellList references.
class SpellReferenceChoiceSet {
  // The underlying set of CDOMReferences to CDOMListObjects.
  final Set<CDOMReference<dynamic>> _set; // Set<CDOMReference<CDOMListObject<Spell>>>

  SpellReferenceChoiceSet(List<CDOMReference<dynamic>> listRefCollection)
      : _set = {} {
    if (listRefCollection.isEmpty) {
      throw ArgumentError('Choice Collection cannot be empty');
    }
    _set.addAll(listRefCollection);
    if (_set.length != listRefCollection.length) {
      // stub: Logging.log(Level.WARNING, "Found duplicate item in $listRefCollection")
      // TODO: need to trigger a bad GroupingState
    }
  }

  // Returns LST format string; DomainSpellList refs are appended with "DOMAIN." prefix.
  String getLSTformat(bool useAny) {
    // Sort by LST format for determinism (stub: ReferenceUtilities.REFERENCE_SORTER).
    final sorted = _set.toList()
      ..sort((a, b) => a.getLSTformat(false).compareTo(b.getLSTformat(false)));

    final StringBuffer sb = StringBuffer();
    final List<CDOMReference<dynamic>> domainList = [];
    bool needComma = false;

    for (final CDOMReference<dynamic> ref in sorted) {
      // Check if this reference is to a DomainSpellList.
      // stub: ref.getReferenceClass() == DomainSpellList
      if (_isDomainSpellListRef(ref)) {
        domainList.add(ref);
      } else {
        if (needComma) sb.write(Constants.comma);
        sb.write(ref.getLSTformat(false));
        needComma = true;
      }
    }

    for (final CDOMReference<dynamic> ref in domainList) {
      if (needComma) sb.write(Constants.comma);
      sb.write('DOMAIN.');
      sb.write(ref.getLSTformat(false));
      needComma = true;
    }

    return sb.toString();
  }

  // stub: determines whether a reference is to a DomainSpellList
  bool _isDomainSpellListRef(CDOMReference<dynamic> ref) {
    // stub
    final dynamic contained = ref.getContainedObjects();
    if (contained is List && contained.isNotEmpty) {
      return contained.first is DomainSpellList;
    }
    return false;
  }

  Type getChoiceClass() => CDOMListObject;

  // Returns the set of CDOMListObjects from all references.
  Set<CDOMListObject<dynamic>> getSet(dynamic pc) {
    final Set<CDOMListObject<dynamic>> returnSet = {};
    for (final CDOMReference<dynamic> ref in _set) {
      returnSet.addAll(
        ref.getContainedObjects().whereType<CDOMListObject<dynamic>>(),
      );
    }
    return returnSet;
  }

  @override
  int get hashCode => _set.length;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is SpellReferenceChoiceSet) {
      return _set.length == obj._set.length && _set.containsAll(obj._set);
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final CDOMReference<dynamic> listref in _set) {
      state = state.add(listref.getGroupingState());
    }
    // TODO: may need state.compound(GroupingState.allowsUnion)
    return state;
  }
}
