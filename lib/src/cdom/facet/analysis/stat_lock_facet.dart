// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.StatLockFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/helper/stat_lock.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';

/// Tracks [StatLock] objects that lock PCStat values to a fixed formula result.
class StatLockFacet extends AbstractSourcedListFacet<CharID, StatLock>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final locks =
        dfce.getCDOMObject().getListFor(ListKey.getConstant<StatLock>('STAT_LOCKS'));
    if (locks != null) {
      addAll(dfce.getCharID(), locks, dfce.getCDOMObject());
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAllFromSource(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the maximum locked value for [stat], or null if not locked.
  num? getLockedStat(CharID id, PCStat stat) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return null;

    double max = double.negativeInfinity;
    bool hit = false;

    for (final entry in componentMap.entries) {
      final lock = entry.key;
      if (lock.getLockedStat() == stat) {
        for (final source in entry.value) {
          final sourceString =
              source is CDOMObject ? source.getQualifiedKey() : '';
          final val =
              formulaResolvingFacet.resolve(id, lock.getLockValue(), sourceString);
          if (val.toDouble() > max) {
            hit = true;
            max = val.toDouble();
          }
        }
      }
    }
    return hit ? max : null;
  }
}
