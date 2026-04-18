import '../../../enumeration/char_id.dart';
import '../event/scope_facet_change_event.dart';
import '../event/scope_facet_change_listener.dart';
import 'abstract_list_facet.dart';

// Consolidates scope-facet events into a flat list facet.
abstract class AbstractScopeFacetConsolidator<S, D>
    extends AbstractListFacet<CharID, D>
    implements ScopeFacetChangeListener<CharID, S, D> {

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, S, D> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject());
  }

  @override
  void dataRemoved(ScopeFacetChangeEvent<CharID, S, D> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject());
  }
}
