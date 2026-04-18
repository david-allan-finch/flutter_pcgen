// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/DynamicFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// DynamicFacet is a Facet that tracks all Dynamic Objects that have been
/// granted to a Player Character.
class DynamicFacet extends AbstractScopeFacet<CharID, dynamic, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  /// Adds the active Dynamic to this facet.
  ///
  /// Triggered when one of the Facets to which DynamicFacet listens fires a
  /// DataFacetChangeEvent to indicate Dynamic was added to a Player Character.
  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    dynamic cdo = dfce.getCDOMObject();
    add(dfce.getCharID(), cdo.getCDOMCategory(), cdo, dfce.getSource());
  }

  /// Removes the no-longer active Dynamic from this facet.
  ///
  /// Triggered when one of the Facets to which DynamicFacet listens fires a
  /// DataFacetChangeEvent to indicate Dynamic was removed from a Player
  /// Character.
  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    dynamic cdo = dfce.getCDOMObject();
    remove(dfce.getCharID(), cdo.getCDOMCategory(), cdo, dfce.getSource());
  }
}
