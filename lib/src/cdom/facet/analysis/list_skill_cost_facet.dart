// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.cdom.facet.analysis.ListSkillCostFacet

import '../../base/cdom_object.dart';
import '../../enumeration/association_key.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/skill_cost.dart';
import '../../../core/skill.dart';
import '../../list/class_skill_list.dart';
import '../base/abstract_sub_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../model/race_facet.dart';

/// Processes SkillCosts associated with the MONCSKILL and MONCCSKILL tokens.
class ListSkillCostFacet extends AbstractSubScopeFacet<ClassSkillList, SkillCost, Skill>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late RaceFacet raceFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    for (final ref in cdo.getModifiedLists()) {
      final useList = ref.getContainedObjects()
          .whereType<ClassSkillList>()
          .toList();
      if (useList.isEmpty) continue;
      final mods = cdo.getListMods(ref);
      for (final skRef in mods) {
        for (final apo in cdo.getListAssociations(ref, skRef)) {
          final sc = apo.getAssociation<SkillCost>(AssociationKey.skillCost);
          if (sc == null) continue;
          for (final csl in useList) {
            for (final skill in skRef.getContainedObjects()) {
              add(id, csl, sc, skill, cdo);
            }
          }
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
  }
}
