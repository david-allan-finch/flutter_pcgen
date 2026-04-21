// Copyright (c) Thomas Parker, 2012-14.
//
// Translation of pcgen.cdom.facet.UsableSkillsFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/sub_scope_facet_change_event.dart';
import 'event/sub_scope_facet_change_listener.dart';
import 'skill_cost_facet.dart';

/// Tracks non-exclusive use-untrained skills (CLASS or CROSSCLASS for any PCClass).
class UsableSkillsFacet extends AbstractSourcedListFacet<CharID, Skill>
    implements SubScopeFacetChangeListener<Skill, SkillCost, PCClass> {
  late SkillCostFacet skillCostFacet;

  @override
  void dataAdded(SubScopeFacetChangeEvent<Skill, SkillCost, PCClass> dfce) {
    final sk = dfce.getScope1();
    if (sk.getSafe(ObjectKey.getConstant('USE_UNTRAINED')) == true) {
      add(dfce.getCharID(), sk, dfce.getSource());
    }
  }

  @override
  void dataRemoved(SubScopeFacetChangeEvent<Skill, SkillCost, PCClass> dfce) {
    final id = dfce.getCharID();
    final sk = dfce.getScope1();
    if (sk.getSafe(ObjectKey.getConstant('USE_UNTRAINED')) == true &&
        !skillCostFacet.containsFor(id, sk)) {
      remove(id, sk, dfce.getSource());
    }
  }

  void init() {
    skillCostFacet.addSubScopeFacetChangeListener(this);
  }
}
