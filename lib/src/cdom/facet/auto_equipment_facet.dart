// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.AutoEquipmentFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_qualified_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// Tracks Equipment objects granted via AUTO:EQUIP on a Player Character.
class AutoEquipmentFacet
    extends AbstractQualifiedListFacet<dynamic>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final list = cdo.getSafeListFor(
        ListKey.getConstant<dynamic>('EQUIPMENT'));
    if (list.isNotEmpty) {
      addAll(dfce.getCharID(), list, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns Equipment objects from all AUTO:EQUIP grants, cloned with qty=1.
  List<Equipment> getAutoEquipment(CharID id) {
    final list = <Equipment>[];
    for (final qo in getQualifiedSet(id)) {
      final ref = qo.getRawObject() as CDOMReference<Equipment>;
      for (final e in ref.getContainedObjects()) {
        final clone = e.clone() as Equipment;
        clone.setQty(1);
        clone.setAutomatic(true);
        list.add(clone);
      }
    }
    return list;
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
