// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.AddFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object_utilities.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_level_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/domain_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// Triggers ADD token processing when a CDOMObject is added/removed from a PC.
class AddFacet implements DataFacetChangeListener<CharID, dynamic> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;
  late DomainFacet domainFacet;
  late ClassLevelFacet classLevelFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final id = dfce.getCharID();
    final aPC = trackingFacet.getPC(id);
    if (!aPC.isImporting()) {
      CDOMObjectUtilities.addAdds(dfce.getCDOMObject(), aPC);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    final id = dfce.getCharID();
    final aPC = trackingFacet.getPC(id);
    if (!aPC.isImporting()) {
      CDOMObjectUtilities.removeAdds(dfce.getCDOMObject(), aPC);
    }
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
    domainFacet.addDataFacetChangeListener(this);
    classLevelFacet.addDataFacetChangeListener(this);
  }
}
