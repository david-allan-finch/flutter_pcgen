// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.EquipmentFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks all Equipment possessed by a Player Character (carried or owned, not
/// necessarily equipped/active).
class EquipmentFacet
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
