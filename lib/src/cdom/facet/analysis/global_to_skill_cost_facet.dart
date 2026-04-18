// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.analysis.GlobalToSkillCostFacet

import '../../enumeration/char_id.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/pc_class.dart';
import '../../../core/skill.dart';
import '../base/abstract_sub_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../event/scope_facet_change_event.dart';
import '../event/scope_facet_change_listener.dart';
import '../model/class_facet.dart';

/// Routes global skill cost entries (from CSKILL/CCSKILL tokens) to each PCClass.
class GlobalToSkillCostFacet extends AbstractSubScopeFacet<PCClass, SkillCost, Skill>
    implements
        ScopeFacetChangeListener<CharID, SkillCost, Skill>,
        DataFacetChangeListener<CharID, PCClass> {
  late ClassFacet classFacet;
  late dynamic globalSkillCostFacet;
  late dynamic globalAddedSkillCostFacet;
  late dynamic masterUsableSkillFacet;

  @override
  void dataAdded(dynamic dfce) {
    if (dfce is ScopeFacetChangeEvent<CharID, SkillCost, Skill>) {
      _onSkillCostAdded(dfce);
    } else if (dfce is DataFacetChangeEvent<CharID, PCClass>) {
      _onClassAdded(dfce);
    }
  }

  void _onSkillCostAdded(ScopeFacetChangeEvent<CharID, SkillCost, Skill> dfce) {
    final id = dfce.getCharID();
    final cost = dfce.getScope();
    final sk = dfce.getCDOMObject();
    final source = dfce.getSource();
    for (final cl in classFacet.getSet(id)) {
      add(id, cl, cost, sk, source);
    }
  }

  void _onClassAdded(DataFacetChangeEvent<CharID, PCClass> dfce) {
    final id = dfce.getCharID();
    final cl = dfce.getCDOMObject();
    final dsID = id.getDatasetID();
    for (final sk in masterUsableSkillFacet.getSet(dsID)) {
      add(id, cl, SkillCost.crossClass, sk, masterUsableSkillFacet);
    }
    for (final cost in globalSkillCostFacet.getScopes(id)) {
      for (final sk in globalSkillCostFacet.getSet(id, cost)) {
        add(id, cl, cost, sk, globalSkillCostFacet);
      }
    }
    for (final cost in globalAddedSkillCostFacet.getScopes(id)) {
      for (final sk in globalAddedSkillCostFacet.getSet(id, cost)) {
        add(id, cl, cost, sk, globalAddedSkillCostFacet);
      }
    }
  }

  @override
  void dataRemoved(dynamic dfce) {
    if (dfce is ScopeFacetChangeEvent<CharID, SkillCost, Skill>) {
      _onSkillCostRemoved(dfce);
    } else if (dfce is DataFacetChangeEvent<CharID, PCClass>) {
      _onClassRemoved(dfce);
    }
  }

  void _onSkillCostRemoved(ScopeFacetChangeEvent<CharID, SkillCost, Skill> dfce) {
    final id = dfce.getCharID();
    final cost = dfce.getScope();
    final sk = dfce.getCDOMObject();
    final source = dfce.getSource();
    for (final cl in classFacet.getSet(id)) {
      remove(id, cl, cost, sk, source);
    }
  }

  void _onClassRemoved(DataFacetChangeEvent<CharID, PCClass> dfce) {
    final id = dfce.getCharID();
    final cl = dfce.getCDOMObject();
    final dsID = id.getDatasetID();
    for (final sk in masterUsableSkillFacet.getSet(dsID)) {
      remove(id, cl, SkillCost.crossClass, sk, masterUsableSkillFacet);
    }
    for (final cost in globalSkillCostFacet.getScopes(id)) {
      for (final sk in globalSkillCostFacet.getSet(id, cost)) {
        remove(id, cl, cost, sk, globalSkillCostFacet);
      }
    }
    for (final cost in globalAddedSkillCostFacet.getScopes(id)) {
      for (final sk in globalAddedSkillCostFacet.getSet(id, cost)) {
        remove(id, cl, cost, sk, globalAddedSkillCostFacet);
      }
    }
  }
}
