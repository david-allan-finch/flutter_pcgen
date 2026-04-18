// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.BioSetTrackingFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../../core/bio_set.dart';
import 'base/abstract_item_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/bio_set_facet.dart';
import 'player_character_tracking_facet.dart';

/// Listens for CDOMObject additions that trigger BioSet randomization
/// (age, height, weight) on the Player Character.
class BioSetTrackingFacet extends AbstractItemFacet<CharID, BioSet>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late BioSetFacet bioSetFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final pc = trackingFacet.getPC(id);
    if (!pc.isImporting()) {
      bioSetFacet.get(id)?.randomize('AGE.HT.WT', pc);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    // Intentionally empty — randomization has no undo.
  }
}
