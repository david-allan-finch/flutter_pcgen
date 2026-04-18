// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.SourcedEquipmentFacet

import '../enumeration/char_id.dart';
import '../../core/equipment.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks Equipment that is active on a Player Character (equipped or natural
/// weapon). Serves as a consolidation point for active equipment.
class SourcedEquipmentFacet
    extends AbstractSourcedListFacet<CharID, Equipment>
    implements DataFacetChangeListener<CharID, Equipment> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, Equipment> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Equipment> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
