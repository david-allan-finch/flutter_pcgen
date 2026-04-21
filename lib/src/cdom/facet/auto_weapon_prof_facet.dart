// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.AutoWeaponProfFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/weapon_prof_provider.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';
import 'base/abstract_qualified_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks [WeaponProfProvider]s granted via AUTO:WEAPONPROF on CDOMObjects.
class AutoWeaponProfFacet
    extends AbstractQualifiedListFacet<WeaponProfProvider>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final weaponProfs = cdo
        .getListFor(ListKey.getConstant<WeaponProfProvider>('WEAPONPROF'));
    if (weaponProfs != null && weaponProfs.isNotEmpty) {
      addAll(dfce.getCharID(), weaponProfs, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns all [WeaponProf]s that have been granted to the character,
  /// resolved from their [WeaponProfProvider]s.
  List<WeaponProf> getWeaponProfs(CharID id) {
    final profs = <WeaponProf>[];
    for (final wpp in getQualifiedSet(id)) {
      profs.addAll(wpp.getContainedProficiencies(id));
    }
    return profs;
  }

  /// Returns true if the character has been granted the specific proficiency.
  bool containsProf(CharID id, WeaponProf wp) {
    for (final wpp in getSet(id)) {
      if (wpp.getContainedProficiencies(id).contains(wp)) {
        return true;
      }
    }
    return false;
  }
}
