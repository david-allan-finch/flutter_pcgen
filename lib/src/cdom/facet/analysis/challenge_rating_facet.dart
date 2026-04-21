// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.ChallengeRatingFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/level_facet.dart';

/// Calculates the Challenge Rating of a Player Character.
class ChallengeRatingFacet {
  late TemplateFacet templateFacet;
  late RaceFacet raceFacet;
  late ClassFacet classFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late BonusCheckingFacet bonusCheckingFacet;
  late LevelFacet levelFacet;

  /// Returns the Challenge Rating of the Player Character, or null if undefined.
  int? getCR(CharID id) {
    int cr = 0;

    if (levelFacet.getMonsterLevelCount(id) == 0) {
      if (levelFacet.getNonMonsterLevelCount(id) == 0) {
        return null;
      }
      cr += _calcClassesCR(id);
    } else {
      final classRaceCR = _calcClassesForRaceCR(id);
      if (classRaceCR == null) return null;
      final raceCR = calcRaceCR(id);
      if (raceCR != null) cr += raceCR;
      cr += classRaceCR;
    }

    cr += _getTemplateCR(id);
    cr += bonusCheckingFacet.getBonus(id, 'MISC', 'CR').toInt();
    return cr;
  }

  /// Returns the CR provided solely by the Race.
  int? calcRaceCR(CharID id) {
    final race = raceFacet.get(id);
    // TODO: race.getSafeObject(ObjectKey.CHALLENGE_RATING).toInteger()
    return 0;
  }

  /// Returns the base racial hit dice count.
  int getBaseHD(CharID id) {
    // TODO: raceFacet.get(id).getSafeObject(ObjectKey.MONSTER_CLASS).getLevelCount()
    return 0;
  }

  int _getTemplateCR(CharID id) {
    return templateFacet
        .getSet(id)
        .fold(0, (sum, t) => sum + t.getCR(levelFacet.getTotalLevels(id), levelFacet.getMonsterLevelCount(id)));
  }

  int _calcClassesCR(CharID id) {
    int cr = 0;
    int crMod = 0;
    int crModPriority = 0;

    for (final pcClass in classFacet.getSet(id)) {
      cr += _calcClassCR(id, pcClass) ?? 0;
      final crmp = _getClassCRModPriority(pcClass);
      if (crmp != 0 && (crmp < crModPriority || crModPriority == 0)) {
        final raceMod = _getClassRaceCRMod(id, pcClass);
        crMod = raceMod ?? _getClassCRMod(id, pcClass);
        crModPriority = crmp;
      }
    }
    return cr + crMod;
  }

  int? _calcClassesForRaceCR(CharID id) {
    // TODO: Full implementation requires game mode monster role lists and CR threshold formula.
    int cr = 0;
    for (final pcClass in classFacet.getSet(id)) {
      final levels = _calcClassCR(id, pcClass);
      if (levels == null) return null;
      cr += levels;
    }
    return cr;
  }

  int? _calcClassCR(CharID id, dynamic pcClass) {
    // TODO: Requires FormulaKey.CR + ClassType CR formula lookup.
    return 0;
  }

  int? _getClassRaceCRMod(CharID id, dynamic pcClass) => null;

  int _getClassCRMod(CharID id, dynamic pcClass) => 0;

  static int _getClassCRModPriority(dynamic pcClass) => 0;

  int getXPAward(CharID id) {
    // TODO: Requires game mode XP awards map.
    final cr = getCR(id);
    return cr == null ? 0 : 0;
  }
}
