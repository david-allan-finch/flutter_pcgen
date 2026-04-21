//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.AbilityUtilities
// AbilityUtilities.dart
// Translated from pcgen/core/AbilityUtilities.java

import 'player_character.dart';
import 'ability.dart';
import 'ability_category.dart';
import 'kit.dart';
import 'globals.dart';
import '../cdom/base/transition_choice.dart';
import '../cdom/base/user_selection.dart';
import '../cdom/content/cn_ability.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/helper/cn_ability_selection.dart';
import 'analysis/add_object_actions.dart';
import 'chooser/choice_manager_list.dart';
import 'chooser/chooser_utilities.dart';
import 'utils/core_utility.dart';
import 'utils/last_group_separator.dart';

/// General utilities related to the Ability class.
class AbilityUtilities {
  AbilityUtilities._();

  static void finaliseAbility(PlayerCharacter aPC, CNAbilitySelection cnas) {
    final CNAbility cna = cnas.getCNAbility();
    final Ability ability = cna.getAbility();

    final TransitionChoice<CNAbility>? mc =
        ability.get(ObjectKey.modifyChoice) as TransitionChoice<CNAbility>?;
    if (mc != null) {
      mc.act(mc.driveChoice(aPC), ability, aPC);
    }

    final List<TransitionChoice<Kit>> kitChoices =
        ability.getSafeListFor(ListKey.kitChoice) as List<TransitionChoice<Kit>>? ?? [];
    for (final TransitionChoice<Kit> kit in kitChoices) {
      kit.act(kit.driveChoice(aPC), ability, aPC);
    }

    aPC.adjustMoveRates();
    AddObjectActions.globalChecks(ability, aPC);
    // Protection for CODE-1240
    aPC.calcActiveBonuses();
  }

  /// Returns the name with sub-choices stripped (the part before the last group).
  static String removeChoicesFromName(String name) {
    final LastGroupSeparator lgs = LastGroupSeparator(name);
    lgs.process();
    return lgs.getRoot().trim();
  }

  /// Parses "foo (bar, baz)" into root "foo" and specifics ["bar", "baz"].
  static String getUndecoratedName(String name, List<String> specifics) {
    final LastGroupSeparator lgs = LastGroupSeparator(name);
    final String? subName = lgs.process();
    final String altName = lgs.getRoot();

    specifics.clear();
    if (subName != null) {
      specifics.addAll(CoreUtility.split(subName, ','));
    }
    return altName.trim();
  }

  /// Whether an association has already been selected for this PC.
  static bool alreadySelected(
      PlayerCharacter pc, Ability ability, String selection, bool allowStack) {
    final List<CNAbility> cnAbilities = pc.getMatchingCNAbilities(ability);
    if (cnAbilities.isEmpty) return false;

    if (!(ability.getSafe(ObjectKey.multipleAllowed) as bool? ?? false)) {
      return true;
    }
    if (allowStack && (ability.getSafe(ObjectKey.stacks) as bool? ?? false)) {
      return false;
    }

    final dynamic info = ability.get(ObjectKey.chooseInfo);
    if (info == null) return false;
    final Object decoded = info.decodeChoice(Globals.getContext(), selection);
    for (final CNAbility cna in cnAbilities) {
      final List<dynamic>? oldSelections = pc.getDetailedAssociations(cna);
      if (oldSelections != null && oldSelections.contains(decoded)) {
        return true;
      }
    }
    return false;
  }

  /// Identify if the object is a feat.
  static bool isFeat(Object? obj) {
    if (obj is! Ability) return false;
    final Ability ability = obj;
    if (ability.getCDOMCategory() == null) return false;
    return ability.getCDOMCategory() == AbilityCategory.feat ||
        ability.getCDOMCategory()?.getParentCategory() == AbilityCategory.feat;
  }

  static Ability? validateCNAList(List<CNAbility> list) {
    Ability? a;
    for (final CNAbility cna in list) {
      if (a == null) {
        a = cna.getAbility();
      } else {
        if (cna.getAbility().getKeyName() != a.getKeyName() ||
            !a.getCDOMCategory()!.equals(cna.getAbilityCategory().getParentCategory())) {
          throw ArgumentError(
              'CNAbility list must be a consistent list of Abilities (same object)');
        }
      }
    }
    return a;
  }

  static void driveChooseAndAdd(CNAbility cna, PlayerCharacter pc, bool toAdd) {
    final Ability ability = cna.getAbility();
    if (!(ability.getSafe(ObjectKey.multipleAllowed) as bool? ?? false)) {
      final CNAbilitySelection cnas = CNAbilitySelection(cna);
      if (toAdd) {
        pc.addAbility(cnas, UserSelection.getInstance(), UserSelection.getInstance());
      } else {
        pc.removeAbility(cnas, UserSelection.getInstance(), UserSelection.getInstance());
      }
    }
    final AbilityCategory category = cna.getAbilityCategory() as AbilityCategory;
    final List<String> reservedList = [];

    final ChoiceManagerList<dynamic>? aMan =
        ChooserUtilities.getConfiguredController(cna, pc, category, reservedList);
    if (aMan != null) {
      _processSelection(pc, cna, aMan, toAdd);
    }
  }

  static void _processSelection<T>(
    PlayerCharacter pc,
    CNAbility cna,
    ChoiceManagerList<T> aMan,
    bool toAdd,
  ) {
    final List<T> availableList = [];
    final List<T> selectedList = [];
    aMan.getChoices(pc, availableList, selectedList);

    if (availableList.isEmpty && selectedList.isEmpty) return;

    final List<T> origSelections = List<T>.from(selectedList);
    final List<T> removedSelections = List<T>.from(selectedList);
    final List<String> reservedList = [];

    List<T> newSelections;
    if (toAdd) {
      newSelections = aMan.doChooser(pc, availableList, selectedList, reservedList);
    } else {
      newSelections = aMan.doChooserRemove(pc, availableList, selectedList, reservedList);
    }

    for (final T obj in newSelections) {
      removedSelections.remove(obj);
    }
    for (final T obj in origSelections) {
      newSelections.remove(obj);
    }

    for (final T sel in newSelections) {
      final String selection = aMan.encodeChoice(sel);
      final CNAbilitySelection cnas = CNAbilitySelection.withSelection(cna, selection);
      pc.addAbility(cnas, UserSelection.getInstance(), UserSelection.getInstance());
    }
    for (final T sel in removedSelections) {
      final String selection = aMan.encodeChoice(sel);
      final CNAbilitySelection cnas = CNAbilitySelection.withSelection(cna, selection);
      pc.removeAbility(cnas, UserSelection.getInstance(), UserSelection.getInstance());
    }
  }
}
