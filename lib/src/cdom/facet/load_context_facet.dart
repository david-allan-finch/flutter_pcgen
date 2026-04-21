// Copyright (c) Thomas Parker, 2018.
//
// Translation of pcgen.cdom.facet.LoadContextFacet

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/data_set_initialization_facet.dart';

/// Stores the LoadContext (weak reference) for each DataSetID.
class LoadContextFacet extends AbstractItemFacet<DataSetID, dynamic>
    implements DataSetInitializedFacet {
  late DataSetInitializationFacet datasetInitializationFacet;

  @override
  void initialize(dynamic context) {
    set(context.getDataSetID(), context);
  }

  void init() {
    datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
