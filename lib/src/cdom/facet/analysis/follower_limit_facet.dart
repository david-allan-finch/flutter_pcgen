// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.FollowerLimitFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_storage_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/cdom_object_consolidation_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/formula_resolving_facet.dart';

/// Tracks FollowerLimit objects (FOLLOWERS token) for a Player Character.
///
/// Cache: Map<CompanionList, Map<FollowerLimit (identity), Set<CDOMObject (identity)>>>
class FollowerLimitFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late BonusCheckingFacet bonusCheckingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final followers = cdo.getListFor(ListKey.getConstant<dynamic>('FOLLOWERS'));
    if (followers != null) {
      for (final fo in followers) {
        _add(dfce.getCharID(), fo, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    _removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void _add(CharID id, dynamic fo, CDOMObject cdo) {
    final cl = fo.companionList.get();
    final foMap = _getConstructingCachedMap(id, cl);
    foMap.putIfAbsent(fo, () => <CDOMObject>{}).add(cdo);
  }

  void _removeAll(CharID id, CDOMObject source) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return;
    componentMap.removeWhere((cl, foMap) {
      foMap.removeWhere((fo, sources) {
        sources.remove(source);
        return sources.isEmpty;
      });
      return foMap.isEmpty;
    });
  }

  /// Returns the maximum number of followers of a given companion list type.
  int getMaxFollowers(CharID id, dynamic companionList) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return 0;
    final foMap = componentMap[companionList];
    if (foMap == null) return 0;
    int max = 0;
    for (final fo in foMap.keys) {
      final val = formulaResolvingFacet
          .resolve(id, fo.followerLimit, '')
          .toInt();
      if (val > max) max = val;
    }
    max += bonusCheckingFacet
        .getBonus(id, 'FOLLOWERS', companionList.toString())
        .toInt();
    return max;
  }

  Map<dynamic, Map<dynamic, Set<CDOMObject>>>? _getCachedMap(CharID id) =>
      getCache(id) as Map<dynamic, Map<dynamic, Set<CDOMObject>>>?;

  Map<dynamic, Set<CDOMObject>> _getConstructingCachedMap(CharID id, dynamic cl) {
    var componentMap = _getCachedMap(id);
    if (componentMap == null) {
      componentMap = {};
      setCache(id, componentMap);
    }
    return componentMap.putIfAbsent(cl, () => {});
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final cm = _getCachedMap(source);
    if (cm != null) {
      for (final entry in cm.entries) {
        for (final foEntry in entry.value.entries) {
          for (final cdo in foEntry.value) {
            _add(copy, foEntry.key, cdo);
          }
        }
      }
    }
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
