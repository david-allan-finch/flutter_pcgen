// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.RemoveFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/persistent_transition_choice.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_level_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/domain_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// Triggers REMOVE token processing when a CDOMObject is added to a PC.
class RemoveFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;
  late DomainFacet domainFacet;
  late ClassLevelFacet classLevelFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final aPC = trackingFacet.getPC(id);
    if (!aPC.isImporting()) {
      final cdo = dfce.getCDOMObject();
      final removeList = cdo.getListFor(
          ListKey.getConstant<PersistentTransitionChoice>('REMOVE'));
      if (removeList != null) {
        for (final tc in removeList) {
          _driveChoice(cdo, tc, aPC);
        }
      }
    }
  }

  static void _driveChoice(
      CDOMObject cdo, PersistentTransitionChoice tc, dynamic pc) {
    tc.act(tc.driveChoice(pc), cdo, pc);
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    // Nothing for now — TODO: make symmetric with dataAdded
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
    domainFacet.addDataFacetChangeListener(this);
    classLevelFacet.addDataFacetChangeListener(this);
  }
}
