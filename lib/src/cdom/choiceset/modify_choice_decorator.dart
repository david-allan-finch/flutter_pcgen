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
// Translation of pcgen.cdom.choiceset.ModifyChoiceDecorator
import 'package:flutter_pcgen/src/cdom/content/cn_ability.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// A PrimitiveChoiceSet that returns the MULT:YES feats possessed by a
// PlayerCharacter that also appear in an underlying set of Ability objects.
// This is a special-case decorator for the MODIFYFEATCHOICE token.
class ModifyChoiceDecorator {
  // The underlying set that identifies Ability (Feat) objects from the LST file.
  final dynamic _pcs; // PrimitiveChoiceSet<Ability>

  ModifyChoiceDecorator(dynamic underlyingSet) : _pcs = underlyingSet;

  Type getChoiceClass() => CNAbility;

  String getLSTformat([bool useAny = false]) => _pcs.getLSTformat(useAny) as String;

  // Returns CNAbility objects that are in the underlying set AND are MULT:YES
  // feats possessed by the PlayerCharacter.
  Set<CNAbility> getSet(dynamic pc) {
    final collection = _pcs.getSet(pc) as Iterable; // Ability objects
    // stub: pc.getPoolAbilities(AbilityCategory.FEAT)
    final List<CNAbility> pcFeats =
        (pc.getPoolAbilities(null) as List).cast<CNAbility>(); // stub
    final Set<CNAbility> returnSet = {};
    for (final CNAbility cna in pcFeats) {
      final dynamic a = cna.getAbility();
      // stub: a.getSafe(ObjectKey.MULTIPLE_ALLOWED)
      final bool multAllowed = a.getSafe(null) as bool; // stub
      if (multAllowed && collection.contains(a)) {
        returnSet.add(cna);
      }
    }
    return returnSet;
  }

  @override
  bool operator ==(Object obj) {
    return obj is ModifyChoiceDecorator && obj._pcs == _pcs;
  }

  @override
  int get hashCode => _pcs.hashCode as int;

  GroupingState getGroupingState() =>
      _pcs.getGroupingState() as GroupingState;
}
