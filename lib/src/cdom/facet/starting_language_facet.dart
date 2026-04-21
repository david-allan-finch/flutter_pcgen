// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.StartingLanguageFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/class_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';

/// Tracks [Language] objects available to a Player Character via the LANGBONUS
/// token (selectable starting languages).
class StartingLanguageFacet extends AbstractSourcedListFacet<CharID, Language>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late ClassFacet classFacet;
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
    classFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final list = cdo.getListMods(Language.startingList);
    if (list != null) {
      final id = dfce.getCharID();
      for (final ref in list) {
        addAll(id, ref.getContainedObjects().toList(), cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }
}
