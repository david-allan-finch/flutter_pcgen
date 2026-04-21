// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.SkillListToCostFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/cdom/list/class_skill_list.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'base/abstract_sub_scope_facet.dart';
import 'event/scope_facet_change_event.dart';
import 'event/scope_facet_change_listener.dart';
import 'master_skill_facet.dart';
import 'model/skill_list_facet.dart';

/// Maps Skills from ClassSkillList objects to their SkillCost for each PCClass.
class SkillListToCostFacet extends AbstractSubScopeFacet<PCClass, SkillCost, Skill>
    implements ScopeFacetChangeListener<CharID, PCClass, ClassSkillList> {
  late SkillListFacet skillListFacet;
  late MasterSkillFacet masterSkillFacet;

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, PCClass, ClassSkillList> dfce) {
    final id = dfce.getCharID();
    final skillList = dfce.getCDOMObject();
    final set = masterSkillFacet.getSet(id.getDatasetID(), skillList);
    if (set != null) {
      final pcc = dfce.getScope();
      for (final s in set) {
        add(id, pcc, SkillCost.classSkill, s, skillList);
      }
    }
  }

  @override
  void dataRemoved(
      ScopeFacetChangeEvent<CharID, PCClass, ClassSkillList> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    skillListFacet.addScopeFacetChangeListener(this);
  }
}
