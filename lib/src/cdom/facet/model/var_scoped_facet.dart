// Copyright (c) Tom Parker, 2016.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

// dynamic: PCGenScoped (not yet translated)

/// VarScopedFacet tracks PCGenScoped objects for a Player Character,
/// used by the formula/variable resolution system.
class VarScopedFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
