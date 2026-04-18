// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

// dynamic: EquipmentModifier, EquipmentHead (not yet translated)
// stub: ListKey.EQMOD used to iterate eqmods from an EquipmentHead

/// ActiveEqModFacet tracks the EqMods that are on EquipmentHeads active on
/// the PlayerCharacter.
class ActiveEqModFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final CharID id = dfce.getCharID();
    final dynamic head = dfce.getCDOMObject();
    // stub: for (EquipmentModifier eqMod in head.getSafeListFor(ListKey.EQMOD)) { add(id, eqMod, head); }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final CharID id = dfce.getCharID();
    final dynamic head = dfce.getCDOMObject();
    // stub: for (EquipmentModifier eqMod in head.getSafeListFor(ListKey.EQMOD)) { remove(id, eqMod, head); }
  }
}
