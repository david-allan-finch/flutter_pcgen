// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.DomainSpellsFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/core/analysis/domain_application.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/class_facet.dart';
import 'model/domain_facet.dart';
import 'player_character_tracking_facet.dart';

/// Tracks Domain Spell lists granted to a Player Character via Domain selections.
class DomainSpellsFacet
    extends AbstractSourcedListFacet<CharID, CDOMList<Spell>>
    implements DataFacetChangeListener<CharID, Domain> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late DomainFacet domainFacet;
  late ClassFacet classFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Domain> dfce) {
    final domain = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final source = domainFacet.getSource(id, domain);
    if (source != null) {
      final classKey = source.getPcclass().getKeyName();
      final domainClass = _getClassKeyed(id, classKey);
      if (domainClass != null) {
        final pc = trackingFacet.getPC(id);
        final maxLevel = pc.getSpellSupport(domainClass).getMaxCastLevel();
        DomainApplication.addSpellsToClassForLevels(
            pc, domain, domainClass, 0, maxLevel);
      }
    }
  }

  PCClass? _getClassKeyed(CharID id, String classKey) {
    for (final aClass in classFacet.getSet(id)) {
      if (aClass.getKeyName().toLowerCase() == classKey.toLowerCase()) {
        return aClass;
      }
    }
    return null;
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Domain> dfce) {
    // Nothing for now — TODO: make symmetric with dataAdded
  }

  void init() {
    domainFacet.addDataFacetChangeListener(this);
  }
}
