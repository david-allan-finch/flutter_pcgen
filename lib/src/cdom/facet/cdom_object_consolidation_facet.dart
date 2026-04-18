// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.CDOMObjectConsolidationFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import 'cdom_object_bridge.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Consolidates all [CDOMObject]s added to a Player Character (from all
/// sources, including Equipment).
///
/// Uses [CDOMObjectBridge] as its underlying data store to break potential
/// listener cycles. If using this facet causes a cycle, use
/// [CDOMObjectSourceFacet] instead — both share the same underlying data.
class CDOMObjectConsolidationFacet
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectBridge bridgeFacet;

  void add(CharID id, CDOMObject obj, Object source) =>
      bridgeFacet.add(id, obj, source);

  void remove(CharID id, CDOMObject obj, Object source) =>
      bridgeFacet.remove(id, obj, source);

  void addDataFacetChangeListener(
          DataFacetChangeListener<CharID, CDOMObject> listener) =>
      bridgeFacet.addDataFacetChangeListener(listener);

  Set<CDOMObject> getSet(CharID id) => bridgeFacet.getSet(id);

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
