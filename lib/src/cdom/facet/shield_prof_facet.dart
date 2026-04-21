// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ShieldProfFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/shield_prof_provider.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/shield_prof_provider_facet.dart';

/// Tracks the ShieldProfs granted to a Player Character via AUTO:SHIELDPROF
/// entries on CDOMObjects.
class ShieldProfFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late ShieldProfProviderFacet shieldProfProviderFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final shieldProfs = cdo
        .getListFor(ListKey.getConstant<ShieldProfProvider>('AUTO_SHIELDPROF'));
    if (shieldProfs.isNotEmpty) {
      shieldProfProviderFacet.addAll(dfce.getCharID(), shieldProfs, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    shieldProfProviderFacet.removeAllFromSource(
        dfce.getCharID(), dfce.getCDOMObject());
  }
}
