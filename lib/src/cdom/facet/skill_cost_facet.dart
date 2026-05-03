// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SkillCostFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sub_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/sub_scope_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/sub_scope_facet_change_listener.dart';

// TODO: wire analysis/input skill cost sub-facets in init() once translated:
//   ListToSkillCostFacet, LocalAddedSkillCostFacet, LocalSkillCostFacet,
//   SkillListToCostFacet, MonCSkillToSkillCostFacet, GlobalToSkillCostFacet.

/// Tracks [SkillCost] assignments for each [Skill]×[PCClass] pair on a PC.
class SkillCostFacet extends AbstractSubScopeFacet<Skill, SkillCost, PCClass>
    implements SubScopeFacetChangeListener<PCClass, SkillCost, Skill> {
  /// Returns the [SkillCost] for [sk] in [aClass] for the PC.
  SkillCost skillCostForPCClass(CharID id, Skill sk, PCClass aClass) {
    if (isClassSkill(id, aClass, sk)) return SkillCost.classSkill;
    if ((sk.getSafeObject(CDOMObjectKey.getConstant('EXCLUSIVE')) as bool? ?? false) &&
        !isCrossClassSkill(id, aClass, sk)) {
      return SkillCost.exclusive;
    }
    return SkillCost.crossClass;
  }

  bool isClassSkill(CharID id, PCClass pcc, Skill skill) =>
      contains(id, skill, SkillCost.classSkill, pcc);

  bool isCrossClassSkill(CharID id, PCClass pcc, Skill skill) =>
      !contains(id, skill, SkillCost.classSkill, pcc) &&
      contains(id, skill, SkillCost.crossClass, pcc);

  @override
  void dataAdded(SubScopeFacetChangeEvent<PCClass, SkillCost, Skill> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getScope2(),
        dfce.getScope1(), dfce.getSource());
  }

  @override
  void dataRemoved(SubScopeFacetChangeEvent<PCClass, SkillCost, Skill> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getScope2(),
        dfce.getScope1(), dfce.getSource());
  }
}
