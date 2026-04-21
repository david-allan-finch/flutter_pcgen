//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.AbilityFromClassChoiceSet
import '../content/cn_ability_factory.dart';
import '../enumeration/grouping_state.dart';
import '../enumeration/nature.dart';
import '../helper/cn_ability_selection.dart';
import '../reference/cdom_single_ref.dart';

// A PrimitiveChoiceSet for CNAbilitySelection objects drawn from a specific
// PCClass. Intended for use during object removal (e.g., REMOVE:FEAT|Class.???),
// not addition.
class AbilityFromClassChoiceSet {
  // The reference to the PCClass this set draws abilities from.
  final CDOMSingleRef<dynamic> _classRef; // CDOMSingleRef<PCClass>

  AbilityFromClassChoiceSet(CDOMSingleRef<dynamic> pcc) : _classRef = pcc;

  String getLSTformat(bool useAny) {
    return 'CLASS.${_classRef.getLSTformat(useAny)}';
  }

  @override
  bool operator ==(Object obj) {
    if (obj is AbilityFromClassChoiceSet) {
      return _classRef == obj._classRef;
    }
    return false;
  }

  @override
  int get hashCode => _classRef.hashCode;

  Type getChoiceClass() => CnAbilitySelection;

  // Returns a set of CNAbilitySelection objects for abilities granted by the
  // class (including per-level abilities). NOTE: the original Java has a known
  // bug where abilityList is always empty; that bug is faithfully reproduced here.
  Set<CnAbilitySelection> getSet(dynamic pc) {
    // stub: pc.getClassKeyed(classRef.get().getKeyName())
    final dynamic aClass =
        pc.getClassKeyed(_classRef.get().getKeyName()); // stub
    final Set<CnAbilitySelection> set = {};
    if (aClass != null) {
      // TODO: This is a bug in the original Java — abilityList is always empty.
      final List<dynamic> abilityList = []; // stub: always empty (bug preserved)
      for (final dynamic aFeat in abilityList) {
        set.add(
          CnAbilitySelection(
            CNAbilityFactory.getCNAbility(
              null, // stub: AbilityCategory.FEAT
              Nature.virtual,
              aFeat,
            ),
          ),
        );
      }
      // stub: pc.getLevel(aClass)
      final int level = pc.getLevel(aClass) as int; // stub
      for (int lvl = 0; lvl < level; lvl++) {
        // stub: pc.getActiveClassLevel(aClass, lvl)
        final dynamic pcl = pc.getActiveClassLevel(aClass, lvl); // stub
        // TODO: This is a bug in the original Java — abilityList is always empty.
        final List<dynamic> levelAbilityList = []; // stub: always empty (bug preserved)
        for (final dynamic aFeat in levelAbilityList) {
          set.add(
            CnAbilitySelection(
              CNAbilityFactory.getCNAbility(
                null, // stub: AbilityCategory.FEAT
                Nature.virtual,
                aFeat,
              ),
            ),
          );
        }
      }
    }
    return set;
  }

  GroupingState getGroupingState() => GroupingState.any;
}
