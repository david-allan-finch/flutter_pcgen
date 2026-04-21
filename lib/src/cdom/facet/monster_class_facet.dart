// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.MonsterClassFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'analysis/level_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'formula_resolving_facet.dart';
import 'level_info_facet.dart';
import 'model/class_facet.dart';
import 'model/race_facet.dart';
import 'player_character_tracking_facet.dart';

/// Applies MONSTERCLASS levels when a CDOMObject is added/removed from a PC.
class MonsterClassFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late LevelFacet levelFacet;
  late ClassFacet classFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late LevelInfoFacet levelInfoFacet;
  late RaceFacet raceFacet;
  late PlayerCharacterTrackingFacet trackingFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final cdo = dfce.getCDOMObject();

    // Preserve and remove existing class data
    final ci = classFacet.removeAllClasses(id);

    // Remove saved monster level info
    for (int i = levelInfoFacet.getCount(id) - 1; i >= 0; --i) {
      final pli = levelInfoFacet.get(id, i);
      final classKeyName = pli.getClassKeyName();
      final aClass = _findClass(classKeyName);
      if (aClass != null && aClass.isMonster()) {
        levelInfoFacet.remove(id, pli);
      }
    }

    final pc = trackingFacet.getPC(id);
    final existingLevelInfo = levelInfoFacet.getSet(id).toList();
    levelInfoFacet.removeAll(id);

    // Add monster class levels first (before existing levels)
    if (!pc.isImporting()) {
      final lcf = cdo.get(ObjectKey.getConstant('MONSTER_CLASS'));
      if (lcf != null) {
        final levelCount =
            formulaResolvingFacet.resolve(id, lcf.getLevelCount(), '').toInt();
        pc.incrementClassLevel(levelCount, lcf.getPCClass(), true);
      }
    }
    levelInfoFacet.addAll(id, existingLevelInfo);

    // Re-add existing non-monster classes and recalculate skill points
    if (!pc.isImporting() && ci != null && !ci.isEmpty()) {
      int totalLevels = levelFacet.getTotalLevels(id);
      for (final pcClass in ci.getClassSet()) {
        if (!pcClass.isMonster()) {
          classFacet.addClass(id, pcClass);
          final cLevels = ci.getLevel(pcClass);
          classFacet.setLevel(id, pcClass, cLevels);
          pc.setSkillPool(pcClass, 0);
          int cMod = 0;
          for (int j = 0; j < cLevels; ++j) {
            cMod += pc.recalcSkillPointMod(pcClass, ++totalLevels);
          }
          pc.setSkillPool(pcClass, cMod);
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final lcf = cdo.get(ObjectKey.getConstant('MONSTER_CLASS'));
    if (lcf != null) {
      final id = dfce.getCharID();
      final levelCount =
          formulaResolvingFacet.resolve(id, lcf.getLevelCount(), '').toInt();
      final pc = trackingFacet.getPC(id);
      pc.incrementClassLevel(-levelCount, lcf.getPCClass(), true);
    }
  }

  PCClass? _findClass(String key) {
    // Placeholder — needs Globals.getContext() equivalent
    return null;
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
  }
}
