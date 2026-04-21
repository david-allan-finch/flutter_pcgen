// Copyright (c) Thomas Parker, 2014.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/scope_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/scope_facet_change_listener.dart';

// dynamic: PCClass, ClassSkillList (not yet translated)

/// SkillListFacet stores the SkillList objects for a PCClass of a Player
/// Character, keyed by (CharID, PCClass) → ClassSkillList.
class SkillListFacet extends AbstractScopeFacet<CharID, dynamic, dynamic>
    implements ScopeFacetChangeListener<CharID, dynamic, dynamic> {

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getScope(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(ScopeFacetChangeEvent<CharID, dynamic, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getScope(), dfce.getCDOMObject(), dfce.getSource());
  }
}
