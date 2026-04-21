// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.MasterAvailableSpellFacet

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/available_spell.dart';
import 'base/abstract_list_facet.dart';
import 'data_set_initialization_facet.dart';

/// Caches all available spells from class/domain spell lists for a dataset.
/// This is dataset-global (uses [DataSetID] not [CharID]).
class MasterAvailableSpellFacet extends AbstractListFacet<DataSetID, AvailableSpell>
    implements DataSetInitializedFacet {
  late DataSetInitializationFacet datasetInitializationFacet;

  @override
  void initialize(dynamic context) {
    final dsID = context.getDataSetID() as DataSetID;
    // TODO: iterate master spell lists from context and populate
    // This requires SettingsHandler.getGame().getMasterLists() equivalent
  }

  void init() {
    datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
