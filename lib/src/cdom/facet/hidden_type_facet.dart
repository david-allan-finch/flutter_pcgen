// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.HiddenTypeFacet

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'base/abstract_scope_facet.dart';

// TODO: wire DataSetInitializationFacet.addDataSetInitializedFacet once translated.
// TODO: implement initialize(LoadContext) once LoadContext is translated.

/// Tracks [Type] values that are hidden from the user for various object
/// classes (Equipment, Ability, Skill), keyed by [DataSetID] and class token.
class HiddenTypeFacet extends AbstractScopeFacet<DataSetID, String, Type> {
  void init() {
    // datasetInitializationFacet.addDataSetInitializedFacet(this);
  }

  /// Loads hidden types from [campaign] into [id].
  void loadCampaignHiddenTypes(DataSetID id, Campaign campaign) {
    _loadHiddenTypes(
        id, 'EQUIPMENT', ListKey.getConstant<String>('HIDDEN_Equipment'), campaign);
    _loadHiddenTypes(
        id, 'ABILITY', ListKey.getConstant<String>('HIDDEN_Ability'), campaign);
    _loadHiddenTypes(
        id, 'SKILL', ListKey.getConstant<String>('HIDDEN_Skill'), campaign);
    for (final sub in campaign.getSubCampaigns()) {
      loadCampaignHiddenTypes(id, sub);
    }
  }

  void _loadHiddenTypes(
      DataSetID id, String classKey, ListKey<String> listKey, Campaign c) {
    for (final s in c.getSafeListFor(listKey)) {
      add(id, classKey, Type.getConstant(s), c);
    }
  }
}
