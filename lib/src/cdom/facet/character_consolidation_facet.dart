// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.CharacterConsolidationFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Consolidates all [CDOMObject]s that are natively part of a Player Character
/// (not from equipped Equipment).
///
/// For a consolidation point that includes both native and equipment-sourced
/// CDOMObjects, see [CDOMObjectConsolidationFacet].
class CharacterConsolidationFacet
    extends AbstractSourcedListFacet<CharID, CDOMObject>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }
}
