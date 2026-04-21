// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.LocalSkillCostFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sub_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_level_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/domain_facet.dart';

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
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  PCClass? _getOwner(CharID id, CDOMObject cdo) {
    if (cdo is Domain) {
      return domainFacet.getSource(id, cdo)?.getPcclass();
    } else if (cdo is PCClassLevel) {
      return cdo.getObject(ObjectKey.getConstant('PARENT')) as PCClass?;
    } else if (cdo is PCClass) {
      return cdo;
    }
    return null;
  }
}
