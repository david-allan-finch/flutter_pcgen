// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.NaturalWeaponProfFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks the [WeaponProf]s implicitly granted via NATURALATTACKS tokens on
/// CDOMObjects added to a Player Character.
class NaturalWeaponProfFacet
    extends AbstractSourcedListFacet<CharID, WeaponProf>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final iwp = cdo.getListFor(
        ListKey.getConstant<CDOMSingleRef<WeaponProf>>('IMPLIED_WEAPONPROF'));
    if (iwp.isNotEmpty) {
      final id = dfce.getCharID();
      for (final ref in iwp) {
        add(id, ref.get(), cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }
}
