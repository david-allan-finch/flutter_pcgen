// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.ListToSkillCostFacet

import '../../enumeration/char_id.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/pc_class.dart';
import '../../../core/skill.dart';
import '../../list/class_skill_list.dart';
import '../base/abstract_sub_scope_facet.dart';
import '../event/scope_facet_change_event.dart';
import '../event/scope_facet_change_listener.dart';
import '../event/sub_scope_facet_change_event.dart';
import '../event/sub_scope_facet_change_listener.dart';
import '../model/skill_list_facet.dart';

/// Maps MONCSKILL/MONCCSKILL skills to SkillCost per PCClass.
class ListToSkillCostFacet extends AbstractSubScopeFacet<PCClass, SkillCost, Skill>
    implements
        ScopeFacetChangeListener<CharID, PCClass, ClassSkillList>,
        SubScopeFacetChangeListener<ClassSkillList, SkillCost, Skill> {
  late SkillListFacet skillListFacet;
  late dynamic listSkillCostFacet;

  @override
  void dataAdded(dynamic dfce) {
    if (dfce is ScopeFacetChangeEvent<CharID, PCClass, ClassSkillList>) {
      final id = dfce.getCharID();
      final pcc = dfce.getScope();
      final skillList = dfce.getCDOMObject();
      for (final sk in listSkillCostFacet.getSet(id, skillList, SkillCost.classSkill)) {
        add(id, pcc, SkillCost.classSkill, sk, pcc);
      }
      for (final sk in listSkillCostFacet.getSet(id, skillList, SkillCost.crossClass)) {
        add(id, pcc, SkillCost.crossClass, sk, pcc);
      }
    } else if (dfce is SubScopeFacetChangeEvent<ClassSkillList, SkillCost, Skill>) {
      final id = dfce.getCharID();
      final skillList = dfce.getScope1();
      final cost = dfce.getScope2();
      final sk = dfce.getCDOMObject();
      for (final cl in skillListFacet.getScopes(id)) {
        if (skillListFacet.contains(id, cl, skillList)) {
          add(id, cl, cost, sk, cl);
        }
      }
    }
  }

  @override
  void dataRemoved(dynamic dfce) {
    if (dfce is ScopeFacetChangeEvent<CharID, PCClass, ClassSkillList>) {
      removeAllFromSource(dfce.getCharID(), dfce.getScope());
    } else if (dfce is SubScopeFacetChangeEvent<ClassSkillList, SkillCost, Skill>) {
      final id = dfce.getCharID();
      final skillList = dfce.getScope1();
      final cost = dfce.getScope2();
      final sk = dfce.getCDOMObject();
      for (final cl in skillListFacet.getScopes(id)) {
        if (skillListFacet.contains(id, cl, skillList)) {
          remove(id, cl, cost, sk, cl);
        }
      }
    }
  }

  void init() {
    skillListFacet.addScopeFacetChangeListener(this);
    listSkillCostFacet.addSubScopeFacetChangeListener(this);
  }
}
