// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ArmorProfFacet

import '../base/cdom_object.dart';
import '../enumeration/char_id.dart';
import '../enumeration/list_key.dart';
import '../helper/armor_prof_provider.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/armor_prof_provider_facet.dart';

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
