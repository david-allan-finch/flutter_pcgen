// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.EquipmentTypeFacet

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart';
import 'base/abstract_list_facet.dart';

// TODO: wire DataSetInitializationFacet.addDataSetInitializedFacet once translated.
// TODO: implement initialize(LoadContext) once LoadContext is translated.

/// Tracks all [Type] tags present on any [Equipment] object in a dataset.
///
/// Populated at dataset load time via [initialize].
class EquipmentTypeFacet extends AbstractListFacet<DataSetID, Type> {
  // DataSetInitializationFacet not yet translated; init() wired manually.
  void init() {
    // datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
