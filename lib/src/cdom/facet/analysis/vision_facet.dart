// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.VisionFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/qualified_object.dart';
import 'package:flutter_pcgen/src/core/vision.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/prerequisite_facet.dart';

/// Tracks Vision objects contained in a Player Character.
class VisionFacet extends AbstractSourcedListFacet<CharID, QualifiedObject<Vision>>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late BonusCheckingFacet bonusCheckingFacet;
  late PrerequisiteFacet prerequisiteFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final mods = cdo.getListMods(Vision.visionList);
    if (mods == null) return;
    final id = dfce.getCharID();
    for (final ref in mods) {
      final assoc = cdo.getListAssociations(Vision.visionList, ref);
      for (final apo in assoc) {
        final prereqs = apo.getPrerequisiteList();
        for (final v in ref.getContainedObjects()) {
          add(id, QualifiedObject(v, prereqs), cdo);
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns all active Vision objects (after prerequisites and bonus-based additions).
  List<Vision> getActiveVision(CharID id) {
    final componentMap = getCachedMap(id);
    final map = <String, int>{}; // VisionType key → distance

    if (componentMap != null) {
      for (final entry in componentMap.entries) {
        final qo = entry.key;
        for (final source in entry.value) {
          if (prerequisiteFacet.qualifies(id, qo, source)) {
            final sourceStr = (source is CDOMObject) ? source.getQualifiedKey() : '';
            final v = qo.rawObject;
            final dist = formulaResolvingFacet
                .resolve(id, v.distance, sourceStr)
                .toInt();
            final typeKey = v.type.toString();
            final current = map[typeKey] ?? 0;
            if (dist > current) map[typeKey] = dist;
          }
        }
      }
    }

    // Add BONUS:VISION entries.
    for (final vType in Vision.getAllVisionTypes()) {
      final aVal = bonusCheckingFacet.getBonus(id, 'VISION', vType.toString()).toInt();
      if (aVal > 0) {
        final current = map[vType.toString()] ?? 0;
        map[vType.toString()] = aVal + current;
      }
    }

    return map.entries
        .map((e) => Vision(e.key, e.value))
        .toList()
      ..sort();
  }

  /// Returns the Vision of the given type, or null.
  Vision? getActiveVisionOfType(CharID id, String visionType) {
    return getActiveVision(id)
        .where((v) => v.type == visionType)
        .firstOrNull;
  }

  int getVisionCount(CharID id) => getActiveVision(id).length;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
