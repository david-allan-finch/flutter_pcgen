// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.NaturalEquipSetFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'natural_weapon_facet.dart';
import 'player_character_tracking_facet.dart';

/// Listens for natural [Equipment] additions and automatically adds them to
/// the PC's default EquipSet.
class NaturalEquipSetFacet
    implements DataFacetChangeListener<CharID, Equipment> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late NaturalWeaponFacet naturalWeaponFacet;

  void init() {
    naturalWeaponFacet.addDataFacetChangeListener(this, priority: 1);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Equipment> dfce) {
    final pc = trackingFacet.getPC(dfce.getCharID());
    final eSet = pc.getEquipSetByIdPath('0.1');
    if (eSet != null) {
      final eq = dfce.getCDOMObject();
      final es = pc.addEquipToTarget(eSet, null, '', eq, null);
      if (es == null) {
        pc.addEquipToTarget(eSet, null, 'Carried', eq, null);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Equipment> dfce) {
    // TODO: establish symmetry for natural equipment removal.
  }
}
