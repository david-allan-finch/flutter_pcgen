// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ArmorProfFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/armor_prof_provider.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/armor_prof_provider_facet.dart';

/// Tracks the ArmorProfs granted to a Player Character via AUTO:ARMORPROF
/// entries on CDOMObjects.
class ArmorProfFacet implements DataFacetChangeListener<CharID, CDOMObject> {
  late ArmorProfProviderFacet armorProfProviderFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final armorProfs = cdo
        .getListFor(ListKey.getConstant<ArmorProfProvider>('AUTO_ARMORPROF'));
    if (armorProfs.isNotEmpty) {
      armorProfProviderFacet.addAll(dfce.getCharID(), armorProfs, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    armorProfProviderFacet.removeAllFromSource(
        dfce.getCharID(), dfce.getCDOMObject());
  }
}
