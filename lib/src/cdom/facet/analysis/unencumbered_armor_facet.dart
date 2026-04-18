// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.UnencumberedArmorFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/object_key.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_source_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import 'load_facet.dart';

/// Tracks Load values for Unencumbered Armor locked on a Player Character.
class UnencumberedArmorFacet extends AbstractSourcedListFacet<CharID, Load>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectSourceFacet cdomSourceFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final load = cdo.get(ObjectKey.getConstant<Load>('UNENCUMBERED_ARMOR'));
    if (load != null) {
      add(dfce.getCharID(), load, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the best (highest) Load value that avoids armor encumbrance.
  Load getBestLoad(CharID id) {
    final loadSet = getSet(id);
    if (loadSet.isEmpty) return Load.light;
    return loadSet.reduce((a, b) => a.index > b.index ? a : b);
  }

  /// Returns true if the Player Character can ignore the given Load for armor encumbrance.
  bool ignoreLoad(CharID id, Load load) =>
      getBestLoad(id).index >= load.index;

  void init() {
    cdomSourceFacet.addDataFacetChangeListener(this);
  }
}
