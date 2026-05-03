// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.TemplateFeatFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// Tracks CNAbilitySelection objects granted via FEAT tokens on PCTemplates.
class TemplateFeatFacet
    extends AbstractSourcedListFacet<CharID, CNAbilitySelection>
    implements DataFacetChangeListener<CharID, PCTemplate> {
  late TemplateFacet templateFacet;
  late PlayerCharacterTrackingFacet trackingFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final id = dfce.getCharID();
    final source = dfce.getCDOMObject();
    if (!containsFrom(id, source)) {
      final choice = source.getObject(CDOMObjectKey.getConstant('TEMPLATE_FEAT'));
      if (choice != null) {
        final pc = trackingFacet.getPC(id);
        final result = choice.driveChoice(pc);
        choice.act(result, source, pc);
        for (final cas in result) {
          add(id, cas, source);
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final id = dfce.getCharID();
    final source = dfce.getCDOMObject();
    final choice = source.getObject(CDOMObjectKey.getConstant('TEMPLATE_FEAT'));
    if (choice != null) {
      final pc = trackingFacet.getPC(id);
      choice.remove(source, pc);
    }
    removeAllFromSource(id, source);
  }

  void init() {
    templateFacet.addDataFacetChangeListener(this);
  }
}
