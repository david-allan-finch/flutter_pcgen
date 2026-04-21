//
// Copyright 2005 (C) Andrew Wilson <nuance@sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.kit.KitAbilities
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/content/cn_ability.dart';
import 'package:flutter_pcgen/src/cdom/content/cn_ability_factory.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'base_kit.dart';

// Kit task that grants abilities to a PC.
final class KitAbilities extends BaseKit {
  bool? free;
  int? choiceCount;
  final List<CDOMReference<Ability>> _abilities = [];
  CDOMSingleRef<AbilityCategory>? catRef;

  // Transient state
  List<CnAbilitySelection>? _abilitiesToAdd;

  void setFree(bool argFree) { free = argFree; }
  bool isFree() => free == true;
  bool? getFree() => free;

  void setCount(int quan) { choiceCount = quan; }
  int? getCount() => choiceCount;
  int getSafeCount() => choiceCount ?? 1;

  void addAbility(CDOMReference<Ability> ref) { _abilities.add(ref); }
  List<CDOMReference<Ability>> getAbilityKeys() => List.unmodifiable(_abilities);

  void setCategory(CDOMSingleRef<AbilityCategory> ac) { catRef = ac; }
  CDOMSingleRef<AbilityCategory>? getCategory() => catRef;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _abilitiesToAdd = [];
    double minCost = double.maxFinite;
    final available = <_AbilitySelection>[];

    for (final ref in _abilities) {
      final choice = ref.getChoice();
      for (final a in ref.getContainedObjects()) {
        if (a == null) {
          warnings.add('ABILITY: $ref could not be found.');
          minCost = 0;
          continue;
        }
        if (a.getCost() < minCost) minCost = a.getCost();
        if (choice == null && a.getSafeObject(ObjectKey.getConstant('MULT')) == true) {
          available.add(_AbilitySelection(a, ''));
        } else {
          available.add(_AbilitySelection(a, choice));
        }
      }
    }

    int numberOfChoices = getSafeCount();
    if (numberOfChoices > available.length) numberOfChoices = available.length;

    final AbilityCategory category = catRef!.get();
    bool tooManyAbilities = false;
    int maxChoices = minCost > 0.0
        ? (aPC.getAvailableAbilityPool(category) / minCost).toInt()
        : numberOfChoices;
    if (!isFree() && numberOfChoices > maxChoices) {
      numberOfChoices = maxChoices;
      tooManyAbilities = true;
    }
    if (!isFree() && numberOfChoices == 0) {
      warnings.add('ABILITY: Not enough ${category.getPluralName()} available to take "$this"');
      return false;
    }

    List<_AbilitySelection> selected;
    if (numberOfChoices == available.length) {
      selected = available;
    } else {
      selected = available.take(numberOfChoices).toList();
    }

    for (final as_ in selected) {
      final ability = as_.ability;
      if (isFree()) {
        aPC.adjustAbilities(category, 1.0);
      }
      if (ability.getCost() > aPC.getAvailableAbilityPool(category)) {
        tooManyAbilities = true;
      } else {
        final cna = CnAbilityFactory.getCNAbility(category, Nature.normal, ability);
        final cnas = CnAbilitySelection(cna, as_.selection);
        _abilitiesToAdd!.add(cnas);
        aPC.addAbility(cnas, null, this);
      }
    }

    if (tooManyAbilities) {
      warnings.add('ABILITY: Some Abilities were not granted -- not enough remaining feats');
      return false;
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    for (final cnas in _abilitiesToAdd!) {
      aPC.addAbility(cnas, null, null);
      if (isFree()) {
        aPC.adjustAbilities(catRef!.get(), 1.0);
      }
    }
  }

  @override
  String getObjectName() => 'Abilities';

  @override
  String toString() {
    final sb = StringBuffer();
    if (choiceCount != null || _abilities.length != 1) {
      sb.write('${getSafeCount()} of ');
    }
    bool firstDone = false;
    for (final ref in _abilities) {
      if (firstDone) sb.write('; ');
      firstDone = true;
      final choice = ref.getChoice();
      for (final a in ref.getContainedObjects()) {
        if (a != null) {
          sb.write(a.getKeyName());
          if (choice != null) {
            sb.write(' ($choice)');
          }
        }
      }
    }
    if (isFree()) sb.write(' (free)');
    return sb.toString();
  }
}

class _AbilitySelection implements Comparable<_AbilitySelection> {
  final Ability ability;
  final String? selection;

  _AbilitySelection(this.ability, this.selection);

  @override
  String toString() {
    final sb = StringBuffer(ability.getDisplayName());
    if (selection != null) sb.write(' ($selection)');
    return sb.toString();
  }

  @override
  int compareTo(_AbilitySelection o) {
    final base = ability.compareTo(o.ability);
    if (base != 0) return base;
    if (selection == null) return o.selection == null ? 0 : -1;
    if (o.selection == null) return 1;
    return selection!.toLowerCase().compareTo(o.selection!.toLowerCase());
  }
}
