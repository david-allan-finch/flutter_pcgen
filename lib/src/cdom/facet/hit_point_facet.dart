// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.HitPointFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/content/hit_die.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/settings_handler.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_association_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

// TODO: wire LevelFacet once analysis/LevelFacet is translated.

/// Stores the hit points for each [PCClassLevel] on a Player Character, and
/// rolls new HP when class levels are added.
class HitPointFacet extends AbstractAssociationFacet<CharID, PCClassLevel, int>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late ClassFacet classFacet;
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;
  late BonusCheckingFacet bonusCheckingFacet;

  /// Total class levels — TODO: replace with LevelFacet.getTotalLevels once available.
  int _getTotalLevels(CharID id) {
    int total = 0;
    for (final pcClass in classFacet.getSet(id)) {
      total += classFacet.getLevel(id, pcClass);
    }
    return total;
  }

  void init() {
    templateFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();
    final pc = trackingFacet.getPC(id);
    if (pc.isImporting()) return;

    bool first = true;
    for (final pcClass in classFacet.getSet(id)) {
      final dieLock = cdo.getObject(ObjectKey.getConstant<dynamic>('HITDIE'));
      if (dieLock != null) {
        for (int level = 1;
            level <= classFacet.getLevel(id, pcClass);
            level++) {
          final baseHD = pcClass.getSafeObject(ObjectKey.getConstant<HitDie>('LEVEL_HITDIE'));
          if (baseHD != getLevelHitDie(id, pcClass, level)) {
            rollHP(id, pcClass, level, first);
            pc.setDirty(true);
          }
        }
      }
      first = false;
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    // TODO: remove hit points for removed PCClassLevel when symmetry is defined.
  }

  /// Returns the effective [HitDie] for [pcClass] at [classLevel], after
  /// applying race and template die locks.
  HitDie getLevelHitDie(CharID id, PCClass pcClass, int classLevel) {
    HitDie currDie =
        pcClass.getSafeObject(ObjectKey.getConstant<HitDie>('LEVEL_HITDIE')) as HitDie;

    final raceLock = raceFacet.get(id)?.getObject(ObjectKey.getConstant<dynamic>('HITDIE'));
    if (raceLock != null) {
      currDie = raceLock.applyProcessor(currDie, pcClass) as HitDie;
    }

    for (final template in templateFacet.getSet(id)) {
      final lock = template.getObject(ObjectKey.getConstant<dynamic>('HITDIE'));
      if (lock != null) {
        currDie = lock.applyProcessor(currDie, pcClass) as HitDie;
      }
    }

    final cl = classFacet.getClassLevel(id, pcClass, classLevel);
    if (cl != null) {
      if (cl.getObject(ObjectKey.getConstant<dynamic>('DONTADD_HITDIE')) != null) {
        return HitDie.zero;
      }
      final lock = cl.getObject(ObjectKey.getConstant<dynamic>('HITDIE'));
      if (lock != null) {
        currDie = lock.applyProcessor(currDie, pcClass) as HitDie;
      }
    }
    return currDie;
  }

  /// Rolls hit points for [pcc] at [level], storing the result.
  void rollHP(CharID id, PCClass pcc, int level, bool first) {
    int roll = 0;
    final lvlDie = getLevelHitDie(id, pcc, level);

    if (lvlDie.getDie() != 0) {
      final min = 1 +
          bonusCheckingFacet.getBonus(id, 'HD', 'MIN').toInt() +
          bonusCheckingFacet
              .getBonus(id, 'HD', 'MIN;CLASS.${pcc.getKeyName()}')
              .toInt();
      final max = lvlDie.getDie() +
          bonusCheckingFacet.getBonus(id, 'HD', 'MAX').toInt() +
          bonusCheckingFacet
              .getBonus(id, 'HD', 'MAX;CLASS.${pcc.getKeyName()}')
              .toInt();

      if (first && _maximizeHPAtFirstLevel(pcc, level)) {
        roll = max;
      } else {
        final pc = trackingFacet.getPC(id);
        if (!pc.isImporting()) {
          roll = _rollHP(min, max, _getTotalLevels(id));
        }
      }
      roll += bonusCheckingFacet
          .getBonus(id, 'HP', 'CURRENTMAXPERLEVEL')
          .toInt();
    }

    final classLevel = classFacet.getClassLevel(id, pcc, level - 1);
    if (classLevel != null) {
      set(id, classLevel, roll);
    }
  }

  static int _rollHP(int min, int max, int totalLevel) {
    switch (SettingsHandler.hpRollMethod) {
      case SettingsHandler.hpAverage:
        int roll = max - min;
        if (((totalLevel & 0x01) == 0) && ((roll & 0x01) != 0)) roll++;
        return min + (roll ~/ 2);
      case SettingsHandler.hpAutoMax:
        return max;
      case SettingsHandler.hpAverageRoundedUp:
        return ((min + max) / 2.0).ceil();
      case SettingsHandler.hpUserRolled:
        return 1;
      case SettingsHandler.hpPercentage:
        return (min - 1) +
            ((SettingsHandler.hpPercent * ((max - min) + 1)) ~/ 100);
      default:
        return min +
            (DateTime.now().microsecondsSinceEpoch % ((max - min) + 1)).abs();
    }
  }

  static bool _maximizeHPAtFirstLevel(PCClass pcc, int level) {
    final classAllowsMax =
        !SettingsHandler.hpMaxAtFirstPCClassLevelOnly || pcc.isType('PC');
    return level == 1 && SettingsHandler.hpMaxAtFirstLevel && classAllowsMax;
  }
}
