// Copyright (c) James Dempsey, 2013.
//
// Translation of pcgen.cdom.facet.analysis.StatMaxValueFacet

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

/// Tracks [StatLock] objects that set a maximum value on a PCStat.
class StatMaxValueFacet extends AbstractSourcedListFacet<CharID, StatLock>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final locks = dfce.getCDOMObject()
        .getListFor(ListKey.getConstant<StatLock>('STAT_MAXVALUE'));
    if (locks != null) {
      addAll(dfce.getCharID(), locks, dfce.getCDOMObject());
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  /// Returns the minimum of all maximum-value constraints for [stat], or null.
  num? getStatMaxValue(CharID id, PCStat stat) {
    final componentMap = getCachedMap(id);
    if (componentMap == null) return null;

    double min = double.infinity;
    bool hit = false;

    for (final entry in componentMap.entries) {
      final lock = entry.key;
      if (lock.getLockedStat() == stat) {
        for (final source in entry.value) {
          final sourceString =
              source is CDOMObject ? source.getQualifiedKey() : '';
          final val = formulaResolvingFacet.resolve(
              id, lock.getLockValue(), sourceString);
          if (val.toDouble() < min) {
            hit = true;
            min = val.toDouble();
          }
        }
      }
    }
    return hit ? min : null;
  }
}
