// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.StartingLanguageFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../../core/language.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/class_facet.dart';
import 'model/race_facet.dart';
import 'model/template_facet.dart';

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
