// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.AbilityChooseController

import 'package:flutter_pcgen/src/core/chooser/choice_manager_list.dart';
import 'package:flutter_pcgen/src/core/chooser/choose_controller.dart';

/// Controls pool/stacking for ability-based choosers.
class AbilityChooseController extends ChooseController<dynamic> {
  final dynamic ability;
  final dynamic ac; // AbilityCategory
  final dynamic pc;
  final ChoiceManagerList<dynamic> ccm;

  AbilityChooseController(this.ability, this.ac, this.pc, this.ccm);

  @override
  int getPool() {
    if (isMultYes()) {
      final availPool =
          (pc.getAvailableAbilityPool(ac) as num).toInt();
      return (availPool == 0 && getCost() == 0) ? 1 : availPool;
    }
    return 1;
  }

  @override
  bool isMultYes() =>
      ability.getSafeObject(CDOMObjectKey.getConstant('MULTIPLE_ALLOWED')) as bool? ?? false;

  @override
  bool isStackYes() => ability.getSafeObject(CDOMObjectKey.getConstant('STACKS')) as bool? ?? false;

  @override
  double getCost() =>
      (ability.getSafeObject(CDOMObjectKey.getConstant('SELECTION_COST')) as num? ?? 1).toDouble();

  @override
  int getTotalChoices() => isMultYes() ? 0x7FFFFFFF : 1;

  @override
  void adjustPool(List<dynamic> selected) {
    if (ac == _featCategory) {
      final cost = getCost();
      if (cost > 0) {
        final preChooserChoices = ccm.getPreChooserChoices();
        final choicesPerUnitCost = ccm.getChoicesPerUnitCost();
        final basePriorCost =
            (preChooserChoices + choicesPerUnitCost - 1) ~/ choicesPerUnitCost;
        final baseTotalCost =
            (selected.length + choicesPerUnitCost - 1) ~/ choicesPerUnitCost;
        pc.adjustAbilities(ac, cost * (basePriorCost - baseTotalCost));
      }
    }
  }
}

/// Placeholder — replace with the actual AbilityCategory.FEAT singleton.
dynamic get _featCategory => null;
