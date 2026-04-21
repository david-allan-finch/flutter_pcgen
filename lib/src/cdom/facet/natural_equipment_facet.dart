// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.NaturalEquipmentFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks Equipment of TYPE=Natural granted to a Player Character.
class NaturalEquipmentFacet
    extends AbstractSourcedListFacet<CharID, Equipment>
    implements DataFacetChangeListener<CharID, Equipment> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, Equipment> dfce) {
    final eq = dfce.getCDOMObject();
    if (eq.isNatural()) {
      add(dfce.getCharID(), eq, dfce.getSource());
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Equipment> dfce) {
    // No TYPE check on removal — false removals are safe and cheaper than
    // recomputing Equipment TYPE (which EquipmentModifiers can change).
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
