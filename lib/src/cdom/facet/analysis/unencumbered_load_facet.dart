// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.UnencumberedLoadFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_source_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'load_facet.dart';

/// Tracks Load values for Unencumbered movement locked on a Player Character.
class UnencumberedLoadFacet extends AbstractSourcedListFacet<CharID, Load>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectSourceFacet cdomSourceFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final load = cdo.getObject(ObjectKey.getConstant<Load>('UNENCUMBERED_LOAD'));
    if (load != null) {
      add(dfce.getCharID(), load, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the best (highest) Load value that avoids load encumbrance.
  Load getBestLoad(CharID id) {
    final loadSet = getSet(id);
    if (loadSet.isEmpty) return Load.light;
    return loadSet.reduce((a, b) => a.index > b.index ? a : b);
  }

  /// Returns true if the Player Character can ignore the given Load for load encumbrance.
  bool ignoreLoad(CharID id, Load load) =>
      getBestLoad(id).index >= load.index;

  void init() {
    cdomSourceFacet.addDataFacetChangeListener(this);
  }
}
