// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.HasAnyFavoredClassFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/object_key.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../model/race_facet.dart';
import '../model/template_facet.dart';

/// Tracks if the Player Character has "ANY" ("HIGHESTCLASS") as a Favored Class.
class HasAnyFavoredClassFacet extends AbstractSourcedListFacet<CharID, bool>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late RaceFacet raceFacet;
  late TemplateFacet templateFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final hdw = cdo.get(ObjectKey.getConstant<bool>('ANY_FAVORED_CLASS'));
    if (hdw != null) {
      add(dfce.getCharID(), hdw, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  bool get(CharID id) => contains(id, true);

  void init() {
    raceFacet.addDataFacetChangeListener(this);
    templateFacet.addDataFacetChangeListener(this);
  }
}
