// Copyright (c) Andrew Wilson, 2005.
//
// Translation of pcgen.core.chooser.ChooserUtilities

import 'ability_choose_controller.dart';
import 'cdom_choice_manager.dart';
import 'choice_manager_list.dart';
import 'skill_choose_controller.dart';

/// Utility methods for driving CHOOSE token interactions.
class ChooserUtilities {
  ChooserUtilities._();

  /// Builds, drives, and applies choices for [aPObject].
  ///
  /// Returns true if choices were processed; false if no choice manager could
  /// be found or nothing was available to choose.
  static bool modChoices(
    dynamic aPObject,
    List availableList,
    List selectedList,
    dynamic aPC,
    bool addIt,
    dynamic category,
  ) {
    availableList.clear();
    selectedList.clear();
    final reservedList = <String>[];

    final aMan = getConfiguredController(aPObject, aPC, category, reservedList);
    if (aMan == null) return false;

    aMan.getChoices(aPC, availableList, selectedList);

    if (availableList.isNotEmpty || selectedList.isNotEmpty) {
      if (addIt) {
        final newSelections =
            aMan.doChooser(aPC, availableList, selectedList, reservedList);
        return aMan.applyChoices(aPC, newSelections);
      } else {
        aMan.doChooserRemove(aPC, availableList, selectedList, reservedList);
      }
      return true;
    }
    return false;
  }

  /// Creates a [ChoiceManagerList] configured with the appropriate controller
  /// for [aPObject] (Ability, Skill, or other ChooseDriver).
  static ChoiceManagerList<T>? getConfiguredController<T>(
    dynamic aPObject,
    dynamic aPC,
    dynamic category,
    List<String> reservedList,
  ) {
    final aMan = getChoiceManager<T>(aPObject, aPC);
    if (aMan == null) return null;

    // Check if the driver is a CNAbility
    if (aPObject.runtimeType.toString().contains('CNAbility')) {
      final ability = aPObject.getAbility();
      final cat = category ??
          aPC.getGame().getAbilityCategory(ability.getCategory());
      aMan.setController(AbilityChooseController(ability, cat, aPC, aMan));
      final abilities = aPC.getMatchingCNAbilities(ability) as List;
      for (final cna in abilities) {
        reservedList.addAll(aPC.getAssociationList(cna) as List<String>);
      }
    } else if (aPObject.runtimeType.toString().contains('Skill')) {
      aMan.setController(SkillChooseController(aPObject, aPC));
    }

    return aMan;
  }

  /// Creates a bare [ChoiceManagerList] from [aPObject]'s CHOOSE info.
  static ChoiceManagerList<T>? getChoiceManager<T>(
      dynamic aPObject, dynamic aPC) {
    final chooseInfo = aPObject.getChooseInfo();
    if (chooseInfo == null) return null;
    final selectFormula = aPObject.getSelectFormula();
    final cost = (selectFormula.resolve(aPC, '') as num).toInt();
    return chooseInfo.getChoiceManager(aPObject, cost) as ChoiceManagerList<T>?;
  }
}
