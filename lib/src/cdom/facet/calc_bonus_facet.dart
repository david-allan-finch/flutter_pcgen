// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.CalcBonusFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// Listens for CDOMObject additions/removals and triggers a global bonus
/// recalculation on the Player Character whenever one occurs.
class CalcBonusFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceFacet raceFacet;

  void init() {
    raceFacet.addDataFacetChangeListener(this, priority: 5000);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    trackingFacet.getPC(dfce.getCharID()).calcActiveBonuses();
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    trackingFacet.getPC(dfce.getCharID()).calcActiveBonuses();
  }
}
