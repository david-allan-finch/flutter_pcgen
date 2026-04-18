// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.NaturalWeaponFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../enumeration/list_key.dart';
import '../../core/equipment.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks the natural weapons (TYPE=Natural [Equipment]) granted to a Player
/// Character via CDOMObjects.
class NaturalWeaponFacet
    extends AbstractSourcedListFacet<CharID, Equipment>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final weapons =
        cdo.getListFor(ListKey.getConstant<Equipment>('NATURAL_WEAPON'));
    if (weapons.isNotEmpty) {
      final id = dfce.getCharID();
      for (final e in weapons) {
        add(id, e, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final weapons =
        cdo.getListFor(ListKey.getConstant<Equipment>('NATURAL_WEAPON'));
    if (weapons.isNotEmpty) {
      final id = dfce.getCharID();
      for (final e in weapons) {
        remove(id, e, cdo);
      }
    }
  }
}
