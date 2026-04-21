// Copyright (c) Thomas Parker, 2010-14.
//
// Translation of pcgen.cdom.facet.MasterSkillFacet

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/list/class_skill_list.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/data_set_initialization_facet.dart';

/// Caches class skill lists for fast class-skill checking.
/// Dataset-global: uses [DataSetID] not CharID.
class MasterSkillFacet extends AbstractScopeFacet<DataSetID, ClassSkillList, Skill>
    implements DataSetInitializedFacet {
  late DataSetInitializationFacet datasetInitializationFacet;

  @override
  void initialize(dynamic context) {
    final dsID = context.getDataSetID() as DataSetID;
    if (getCache(dsID) == null) {
      // TODO: populate from SettingsHandler.getGame().getMasterLists()
    }
  }

  /// Returns Skills in [skillList] for the given [dsID], or null if none.
  Set<Skill>? getSet(DataSetID dsID, ClassSkillList skillList) {
    return super.getSet(dsID, skillList);
  }

  void init() {
    datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
