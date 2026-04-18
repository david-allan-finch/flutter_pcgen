// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.LoadFacet

import '../../enumeration/char_id.dart';
import '../bonus_checking_facet.dart';
import '../formula_resolving_facet.dart';
import '../player_character_tracking_facet.dart';
import 'total_weight_facet.dart';

/// Calculates load/encumbrance information for a Player Character.
enum Load { light, medium, heavy, overload }

class LoadFacet {
  late FormulaResolvingFacet formulaResolvingFacet;
  late TotalWeightFacet totalWeightFacet;
  late PlayerCharacterTrackingFacet pcFacet;
  late BonusCheckingFacet bonusCheckingFacet;

  /// Returns the Load category for the Player Character.
  Load getLoadType(CharID id) {
    final weight = totalWeightFacet.getTotalWeight(id);
    final maxLoad = getMaxLoad(id);
    if (maxLoad <= 0) return Load.light;
    final dbl = weight / maxLoad;

    // TODO: Requires Globals.checkRule(SYS_LDPACSK) and game mode load multipliers.
    // For now, use simple fractions.
    if (dbl <= 1.0 / 3.0) return Load.light;
    if (dbl <= 2.0 / 3.0) return Load.medium;
    if (dbl <= 1.0) return Load.heavy;
    return Load.overload;
  }

  /// Returns the maximum load (in lbs) for the Player Character.
  double getMaxLoad(CharID id, [double mult = 1.0]) {
    // TODO: Requires game mode LOADSCORE formula, LoadInfo table, and size multiplier.
    return 0.0;
  }
}
