// Copyright (c) Thomas Parker, 2018.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

// dynamic: Equipment, EquipmentHead (not yet translated)

/// ActiveEqHeadFacet tracks the Equipment objects equipped by a Player
/// Character and provides access to their EquipmentHead objects.
class ActiveEqHeadFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final CharID id = dfce.getCharID();
    final dynamic equipment = dfce.getCDOMObject();
    // stub: for (EquipmentHead head in equipment.getEquipmentHeads()) { add(id, head, equipment); }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final CharID id = dfce.getCharID();
    final dynamic equipment = dfce.getCDOMObject();
    // stub: for (EquipmentHead head in equipment.getEquipmentHeads()) { remove(id, head, equipment); }
  }
}
