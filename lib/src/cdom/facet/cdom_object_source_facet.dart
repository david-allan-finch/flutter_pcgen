// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.CDOMObjectSourceFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'cdom_object_bridge.dart';
import 'event/data_facet_change_listener.dart';

/// Alternate listener source for [CDOMObjectBridge] events.
///
/// Use this instead of [CDOMObjectConsolidationFacet] when the latter would
/// create a cycle — both share the same underlying [CDOMObjectBridge] store
/// and thus produce identical events.
class CDOMObjectSourceFacet {
  late CDOMObjectBridge bridgeFacet;

  void addDataFacetChangeListener(
          DataFacetChangeListener<CharID, CDOMObject> listener) =>
      bridgeFacet.addDataFacetChangeListener(listener);
}
