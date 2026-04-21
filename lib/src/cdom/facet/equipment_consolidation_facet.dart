// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.EquipmentConsolidationFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Consolidates all [CDOMObject]s that come from a Player Character's equipped
/// Equipment (not natively part of the PC themselves).
///
/// For a consolidation point that includes both equipment-sourced and native
/// CDOMObjects, see [CDOMObjectConsolidationFacet].
class EquipmentConsolidationFacet
    extends AbstractSourcedListFacet<CharID, CDOMObject>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
