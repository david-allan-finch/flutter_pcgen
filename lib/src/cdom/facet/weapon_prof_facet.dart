// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.WeaponProfFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks the [WeaponProf]s that have been granted to a Player Character.
class WeaponProfFacet extends AbstractSourcedListFacet<CharID, WeaponProf>
    implements DataFacetChangeListener<CharID, WeaponProf> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, WeaponProf> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, WeaponProf> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
