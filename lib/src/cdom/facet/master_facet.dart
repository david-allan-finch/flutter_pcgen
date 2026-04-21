// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.MasterFacet

import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/character/follower.dart';
import 'base/abstract_item_facet.dart';
import 'model/companion_mod_facet.dart';

/// Tracks the master [Follower] for a companion Player Character, and provides
/// access to companion-modifier formulas from [CompanionModFacet].
class MasterFacet extends AbstractItemFacet<CharID, Follower> {
  late CompanionModFacet companionModFacet;

  /// Returns the MASTER_CHECK_FORMULA from the first matching CompanionMod.
  String getCopyMasterCheck(CharID id) {
    for (final cMod in companionModFacet.getSet(id)) {
      if (cMod.getType().toLowerCase() ==
          get(id)?.getType().getKeyName().toLowerCase()) {
        final formula = cMod.get(StringKey.masterCheckFormula);
        if (formula != null) return formula;
      }
    }
    return Constants.emptyString;
  }

  /// Returns the MASTER_HP_FORMULA from the first matching CompanionMod.
  String getCopyMasterHP(CharID id) {
    for (final cMod in companionModFacet.getSet(id)) {
      if (cMod.getType().toLowerCase() ==
          get(id)?.getType().getKeyName().toLowerCase()) {
        final formula = cMod.get(StringKey.masterHpFormula);
        if (formula != null) return formula;
      }
    }
    return Constants.emptyString;
  }

  /// Returns the MASTER_BAB_FORMULA from the first matching CompanionMod.
  String getCopyMasterBAB(CharID id) {
    for (final cMod in companionModFacet.getSet(id)) {
      if (cMod.getType().toLowerCase() ==
          get(id)?.getType().getKeyName().toLowerCase()) {
        final formula = cMod.get(StringKey.masterBabFormula);
        if (formula != null) return formula;
      }
    }
    return Constants.emptyString;
  }

  /// Returns true if USE_MASTER_SKILL is set for any matching CompanionMod.
  bool getUseMasterSkill(CharID id) {
    for (final cMod in companionModFacet.getSet(id)) {
      if (cMod.getType().toLowerCase() ==
          get(id)?.getType().getKeyName().toLowerCase()) {
        if (cMod.getSafe(ObjectKey.getConstant<bool>('USE_MASTER_SKILL')) ==
            true) {
          return true;
        }
      }
    }
    return false;
  }
}
