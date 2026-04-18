// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ObjectAdditionFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import 'cdom_object_consolidation_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'player_character_tracking_facet.dart';

/// Forwards CDOMObject additions/removals to [PlayerCharacter.processAddition]
/// and [PlayerCharacter.processRemoval], which handle internal PC state updates.
class ObjectAdditionFacet
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    trackingFacet.getPC(dfce.getCharID()).processAddition(dfce.getCDOMObject());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    trackingFacet.getPC(dfce.getCharID()).processRemoval(dfce.getCDOMObject());
  }
}
