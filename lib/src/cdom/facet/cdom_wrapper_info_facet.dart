// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.CDOMWrapperInfoFacet
// Output-layer facet — stores Freemarker/output actors for a DataSetID.

import '../enumeration/data_set_id.dart';
import 'data_set_initialization_facet.dart';

/// Stores output actors (for template rendering) indexed by DataSetID.
/// This is an output-layer concern; not yet fully implemented.
class CDOMWrapperInfoFacet implements DataSetInitializedFacet {
  late DataSetInitializationFacet datasetInitializationFacet;

  final Map<DataSetID, Map<Type, List<dynamic>>> _actorMap = {};

  @override
  void initialize(dynamic context) {
    // TODO: populate output actors for Freemarker/template rendering
  }

  void init() {
    datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
