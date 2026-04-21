// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.GlobalSkillCostFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks global CSKILL/CCSKILL entries from CDOMObjects for a Player Character.
class GlobalSkillCostFacet extends AbstractScopeFacet<CharID, SkillCost, Skill>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    for (final ref in cdo
        .getSafeListFor(ListKey.getConstant<CDOMReference<Skill>>('CSKILL'))) {
      for (final sk in ref.getContainedObjects()) {
        add(id, SkillCost.classSkill, sk, cdo);
      }
    }
    for (final ref in cdo
        .getSafeListFor(ListKey.getConstant<CDOMReference<Skill>>('CCSKILL'))) {
      for (final sk in ref.getContainedObjects()) {
        add(id, SkillCost.crossClass, sk, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
