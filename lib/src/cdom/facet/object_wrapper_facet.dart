// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.ObjectWrapperFacet
// Output-layer facet — stores template model wrappers for FreeMarker rendering.

import 'package:flutter_pcgen/src/cdom/enumeration/data_set_id.dart';
import 'base/abstract_list_facet.dart';
import 'data_set_initialization_facet.dart';

/// Stores PCGenObjectWrapper instances for wrapping objects in template output.
/// This is an output-layer concern; not yet fully implemented.
class ObjectWrapperFacet extends AbstractListFacet<DataSetID, dynamic>
    implements DataSetInitializedFacet {
  late DataSetInitializationFacet datasetInitializationFacet;

  @override
  void initialize(dynamic context) {
    final dsID = context.getDataSetID() as DataSetID;
    // TODO: add CDOMObjectWrapper, CDOMReferenceWrapper, CNAbilitySelectionWrapper
  }

  void init() {
    datasetInitializationFacet.addDataSetInitializedFacet(this);
  }
}
