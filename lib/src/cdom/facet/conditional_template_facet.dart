// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ConditionalTemplateFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/level_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';

/// Tracks conditional Templates granted by HD/LEVEL/REPEATLEVEL tokens.
class ConditionalTemplateFacet extends AbstractListFacet<CharID, PCTemplate>
    implements DataFacetChangeListener<CharID, PCTemplate>, LevelChangeListener {
  late TemplateFacet templateFacet;
  late LevelFacet levelFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final id = dfce.getCharID();
    final totalLevels = levelFacet.getTotalLevels(id);
    final totalHitDice = levelFacet.getMonsterLevelCount(id);
    addAll(id, dfce.getCDOMObject().getConditionalTemplates(totalLevels, totalHitDice));
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCTemplate> dfce) {
    final id = dfce.getCharID();
    final totalLevels = levelFacet.getTotalLevels(id);
    final totalHitDice = levelFacet.getMonsterLevelCount(id);
    removeAll(dfce.getCharID(),
        dfce.getCDOMObject().getConditionalTemplates(totalLevels, totalHitDice));
  }

  @override
  void levelChanged(LevelChangeEvent lce) {
    final id = lce.getCharID();
    final oldSet = getSet(id);
    final totalLevels = levelFacet.getTotalLevels(id);
    final totalHitDice = levelFacet.getMonsterLevelCount(id);

    // Build new map: conditional template → source template (identity keyed)
    final newMap = <int, (PCTemplate cond, PCTemplate source)>{};
    for (final sourceTempl in templateFacet.getSet(id)) {
      for (final condTempl
          in sourceTempl.getConditionalTemplates(totalLevels, totalHitDice)) {
        newMap[identityHashCode(condTempl)] = (condTempl, sourceTempl);
      }
    }

    // Remove templates no longer present
    for (final a in oldSet.toList()) {
      if (!newMap.containsKey(identityHashCode(a))) {
        remove(id, a);
      }
    }
    // Add new templates (identity check)
    for (final entry in newMap.values) {
      final a = entry.$1;
      final found = oldSet.any((t) => identical(t, a));
      if (!found) {
        add(id, a);
      }
    }
  }

  void init() {
    addDataFacetChangeListener(templateFacet);
    templateFacet.addDataFacetChangeListener(this);
  }
}
