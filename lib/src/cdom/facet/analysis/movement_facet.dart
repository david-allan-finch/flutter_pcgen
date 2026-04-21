// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.MovementFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/simple_movement.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks Movement objects (BASE_MOVEMENT + SIMPLEMOVEMENT) for a Player Character.
class MovementFacet extends AbstractSourcedListFacet<CharID, SimpleMovement>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    final baseList = cdo.getListFor(ListKey.getConstant<SimpleMovement>('BASE_MOVEMENT'));
    if (baseList != null) addAll(id, baseList, cdo);
    final simpleList = cdo.getListFor(ListKey.getConstant<SimpleMovement>('SIMPLEMOVEMENT'));
    if (simpleList != null) addAll(id, simpleList, cdo);
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
