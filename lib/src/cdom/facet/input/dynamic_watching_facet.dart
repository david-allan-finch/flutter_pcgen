// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/DynamicWatchingFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// DynamicWatchingFacet is a Facet that determines all Dynamic Objects that have
/// been granted to a Player Character.
class DynamicWatchingFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    CharID id = dfce.getCharID();
    dynamic cdo = dfce.getCDOMObject();
    List<dynamic>? granted = cdo.getListFor('GRANTED'); // ListKey.GRANTED
    if (granted == null) {
      return;
    }
    for (dynamic reference in granted) {
      for (dynamic dynamic_ in reference.getContainedObjects()) {
        add(id, dynamic_, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    CharID id = dfce.getCharID();
    dynamic cdo = dfce.getCDOMObject();
    List<dynamic>? granted = cdo.getListFor('GRANTED'); // ListKey.GRANTED
    if (granted == null) {
      return;
    }
    for (dynamic reference in granted) {
      for (dynamic dynamic_ in reference.getContainedObjects()) {
        remove(id, dynamic_, cdo);
      }
    }
  }
}
