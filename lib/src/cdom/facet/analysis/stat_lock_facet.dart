// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.StatLockFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../../helper/stat_lock.dart';
import '../../../core/pc_stat.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../formula_resolving_facet.dart';

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
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
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
