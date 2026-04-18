// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.GlobalSkillCostFacet

import '../../base/cdom_object.dart';
import '../../base/cdom_reference.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/skill.dart';
import '../base/abstract_scope_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

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
