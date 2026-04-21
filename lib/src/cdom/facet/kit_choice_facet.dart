// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.KitChoiceFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/domain_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/skill_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// Triggers KIT token processing when a CDOMObject is added to a PC.
class KitChoiceFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late RaceFacet raceFacet;
  late DomainFacet domainFacet;
  late SkillFacet skillFacet;
  late TemplateFacet templateFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final id = dfce.getCharID();
    final aPC = trackingFacet.getPC(id);
    if (!aPC.isImporting()) {
      final cdo = dfce.getCDOMObject();
      for (final kit
          in cdo.getSafeListFor(ListKey.getConstant<dynamic>('KIT_CHOICE'))) {
        kit.act(kit.driveChoice(aPC), cdo, aPC);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    // Nothing for now — kits are often fire-and-forget
  }

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    domainFacet.addDataFacetChangeListener(this);
    skillFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
  }
}
