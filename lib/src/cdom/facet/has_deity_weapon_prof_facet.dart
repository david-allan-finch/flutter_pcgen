// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.HasDeityWeaponProfFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/qualified_object.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_qualified_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks whether a Player Character has been granted Deity Weapon Profs
/// (via HAS_DEITY_WEAPONPROF on CDOMObjects).
class HasDeityWeaponProfFacet
    extends AbstractQualifiedListFacet<QualifiedObject<bool>>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final hdw = cdo.getObject(ObjectKey.getConstant<QualifiedObject<bool>>(
        'HAS_DEITY_WEAPONPROF'));
    if (hdw != null) {
      add(dfce.getCharID(), hdw, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns true if the Player Character has been granted Deity Weapon Profs.
  bool hasDeityWeaponProf(CharID id) {
    for (final qo in getQualifiedSet(id)) {
      if (qo.getRawObject()) return true;
    }
    return false;
  }
}
