// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.LocalSkillCostFacet

import '../../base/cdom_object.dart';
import '../../base/cdom_reference.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../enumeration/object_key.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/domain.dart';
import '../../../core/pc_class.dart';
import '../../../core/skill.dart';
import '../../inst/pc_class_level.dart';
import '../base/abstract_sub_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../model/class_facet.dart';
import '../model/class_level_facet.dart';
import '../model/domain_facet.dart';

/// Tracks local CSKILL/CCSKILL costs assigned per PCClass.
class LocalSkillCostFacet extends AbstractSubScopeFacet<PCClass, SkillCost, Skill>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late DomainFacet domainFacet;
  late ClassFacet classFacet;
  late ClassLevelFacet classLevelFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final owner = _getOwner(id, cdo);
    if (owner == null) return;

    for (final ref in cdo.getSafeListFor(
        ListKey.getConstant<CDOMReference<Skill>>('LOCALCSKILL'))) {
      for (final sk in ref.getContainedObjects()) {
        add(id, owner, SkillCost.classSkill, sk, cdo);
      }
    }
    for (final ref in cdo.getSafeListFor(
        ListKey.getConstant<CDOMReference<Skill>>('LOCALCCSKILL'))) {
      for (final sk in ref.getContainedObjects()) {
        add(id, owner, SkillCost.crossClass, sk, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  PCClass? _getOwner(CharID id, CDOMObject cdo) {
    if (cdo is Domain) {
      return domainFacet.getSource(id, cdo)?.getPcclass();
    } else if (cdo is PCClassLevel) {
      return cdo.get(ObjectKey.getConstant('PARENT')) as PCClass?;
    } else if (cdo is PCClass) {
      return cdo;
    }
    return null;
  }
}
