// Copyright (c) Andrew Maitland, 2016.
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 2.1 of the License, or (at your
// option) any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

// dynamic: Ability, CNAbilitySelection (not yet translated)

/// SimpleAbilityFacet tracks Ability objects for a Player Character,
/// populated via CNAbilitySelection events.
class SimpleAbilityFacet extends AbstractListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    // stub: add(dfce.getCharID(), dfce.getCDOMObject().getCNAbility().getAbility())
    final dynamic cnAbilitySelection = dfce.getCDOMObject();
    add(dfce.getCharID(), cnAbilitySelection?.getCNAbility()?.getAbility());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    // stub: remove(dfce.getCharID(), dfce.getCDOMObject().getCNAbility().getAbility())
    final dynamic cnAbilitySelection = dfce.getCDOMObject();
    remove(dfce.getCharID(), cnAbilitySelection?.getCNAbility()?.getAbility());
  }
}
