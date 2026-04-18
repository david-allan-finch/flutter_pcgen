// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.MonCSkillToSkillCostFacet

import '../../enumeration/char_id.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/pc_class.dart';
import '../../../core/skill.dart';
import '../base/abstract_sub_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../model/class_facet.dart';

/// Assigns CLASS skill cost to MONCSKILL skills for monster PCClasses.
class MonCSkillToSkillCostFacet extends AbstractSubScopeFacet<PCClass, SkillCost, Skill>
    implements DataFacetChangeListener<CharID, PCClass> {
  late ClassFacet classFacet;
  late dynamic monsterCSkillFacet;

  /// Called when a Skill is added to the monster class skill list.
  void skillAdded(DataFacetChangeEvent<CharID, Skill> dfce) {
    final id = dfce.getCharID();
    final sk = dfce.getCDOMObject();
    final source = dfce.getSource();
    for (final cl in classFacet.getSet(id)) {
      if (cl.isMonster()) {
        add(id, cl, SkillCost.classSkill, sk, source);
      }
    }
  }

  /// Called when a Skill is removed from the monster class skill list.
  void skillRemoved(DataFacetChangeEvent<CharID, Skill> dfce) {
    final id = dfce.getCharID();
    final sk = dfce.getCDOMObject();
    final source = dfce.getSource();
    for (final cl in classFacet.getSet(id)) {
      if (cl.isMonster()) {
        remove(id, cl, SkillCost.classSkill, sk, source);
      }
    }
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCClass> dfce) {
    final cl = dfce.getCDOMObject();
    if (cl.isMonster()) {
      final id = dfce.getCharID();
      for (final sk in monsterCSkillFacet.getSet(id)) {
        add(id, cl, SkillCost.classSkill, sk, monsterCSkillFacet);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCClass> dfce) {
    final cl = dfce.getCDOMObject();
    if (cl.isMonster()) {
      final id = dfce.getCharID();
      for (final sk in monsterCSkillFacet.getSet(id)) {
        remove(id, cl, SkillCost.classSkill, sk, monsterCSkillFacet);
      }
    }
  }
}
