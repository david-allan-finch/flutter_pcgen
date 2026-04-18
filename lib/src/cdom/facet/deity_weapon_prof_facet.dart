// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.DeityWeaponProfFacet

import '../base/cdom_reference.dart';
import '../enumeration/char_id.dart';
import '../enumeration/list_key.dart';
import '../../core/deity.dart';
import '../../core/weapon_prof.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks the [WeaponProf]s granted to a Player Character via their Deity
/// selection (DEITYWEAPON token).
class DeityWeaponProfFacet
    extends AbstractSourcedListFacet<CharID, WeaponProf>
    implements DataFacetChangeListener<CharID, Deity> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, Deity> dfce) {
    final deity = dfce.getCDOMObject();
    final weaponList = deity
        .getListFor(ListKey.getConstant<CDOMReference<WeaponProf>>('DEITYWEAPON'));
    if (weaponList != null) {
      for (final ref in weaponList) {
        for (final wp in ref.getContainedObjects()) {
          if (!wp.isType('Natural')) {
            add(dfce.getCharID(), wp, dfce.getCDOMObject());
          }
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Deity> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }
}
