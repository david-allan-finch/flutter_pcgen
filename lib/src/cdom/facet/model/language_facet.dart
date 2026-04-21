// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

// stub: CorePerspectiveDB.register(CorePerspective.LANGUAGE, FacetBehavior.MODEL, this)
// stub: OutputDB.register("languages", this)
// dynamic: Language (not yet translated)

/// LanguageFacet tracks the Languages that have been granted to a Player
/// Character.
class LanguageFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  String getIdentity() => 'Character Languages';

  void init() {
    // stub: CorePerspectiveDB.register(CorePerspective.LANGUAGE, FacetBehavior.MODEL, this)
    // stub: OutputDB.register("languages", this)
  }
}
