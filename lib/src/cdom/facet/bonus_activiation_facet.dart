// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.BonusActiviationFacet
// Note: original Java has a typo ("Activiation") preserved for traceability.

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/companion_mod_facet.dart';
import 'model/domain_facet.dart';
import 'model/race_facet.dart';
import 'model/skill_facet.dart';
import 'model/template_facet.dart';
import 'player_character_tracking_facet.dart';

/// Listens for CDOMObject additions and calls [CDOMObject.activateBonuses] on
/// the Player Character, unless the PC is currently importing.
class BonusActiviationFacet
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceFacet raceFacet;
  late CompanionModFacet companionModFacet;
  late DomainFacet domainFacet;
  late SkillFacet skillFacet;
  late TemplateFacet templateFacet;

  void init() {
    raceFacet.addDataFacetChangeListener(this, priority: 1000);
    companionModFacet.addDataFacetChangeListener(this, priority: 1000);
    domainFacet.addDataFacetChangeListener(this, priority: 1000);
    skillFacet.addDataFacetChangeListener(this, priority: 1000);
    templateFacet.addDataFacetChangeListener(this, priority: 1000);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final pc = trackingFacet.getPC(dfce.getCharID());
    if (!pc.isImporting()) {
      dfce.getCDOMObject().activateBonuses(pc);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    // TODO: consider calling deactivateBonuses for symmetry
  }
}
