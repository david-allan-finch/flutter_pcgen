// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.VariableFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/variable_key.dart';
import '../base/abstract_storage_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';
import '../formula_resolving_facet.dart';

/// Tracks Variables (DEFINE entries) contained in a Player Character.
///
/// Cache structure: Map<VariableKey, Map<Formula, Set<CDOMObject (identity)>>>
class VariableFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late FormulaResolvingFacet formulaResolvingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final id = dfce.getCharID();
    for (final vk in cdo.getVariableKeys()) {
      _add(id, vk, cdo.get(vk), cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void _add(CharID id, VariableKey vk, dynamic formula, CDOMObject cdo) {
    final map = _getConstructingCachedMap(id);
    final subMap = map.putIfAbsent(vk, () => {});
    subMap.putIfAbsent(formula, () => {}).add(cdo);
  }

  void removeAll(CharID id, Object source) {
    final vkMap = _getCachedMap(id);
    if (vkMap == null) return;
    vkMap.removeWhere((vk, fMap) {
      fMap.removeWhere((f, sources) {
        sources.remove(source);
        return sources.isEmpty;
      });
      return fMap.isEmpty;
    });
  }

  /// Returns the variable value for the given VariableKey.
  /// If multiple values exist, returns max (isMax=true) or min (isMax=false).
  double? getVariableValue(CharID id, VariableKey key, bool isMax) {
    final vkMap = _getCachedMap(id);
    if (vkMap == null) return null;
    final fMap = vkMap[key];
    if (fMap == null) return null;
    double? returnValue;
    for (final entry in fMap.entries) {
      final formula = entry.key;
      for (final source in entry.value) {
        final newVal = formulaResolvingFacet
            .resolve(id, formula, source.getQualifiedKey())
            .toDouble();
        if (returnValue == null) {
          returnValue = newVal;
        } else if ((returnValue > newVal) ^ isMax) {
          returnValue = newVal;
        }
      }
    }
    return returnValue;
  }

  bool contains(CharID id, VariableKey vk) =>
      _getCachedMap(id)?.containsKey(vk) ?? false;

  int getVariableCount(CharID id) => _getCachedMap(id)?.length ?? 0;

  Map<VariableKey, Map<dynamic, Set<CDOMObject>>>? _getCachedMap(CharID id) =>
      getCache(id) as Map<VariableKey, Map<dynamic, Set<CDOMObject>>>?;

  Map<VariableKey, Map<dynamic, Set<CDOMObject>>> _getConstructingCachedMap(CharID id) {
    var map = _getCachedMap(id);
    if (map == null) {
      map = {};
      setCache(id, map);
    }
    return map;
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final cm = _getCachedMap(source);
    if (cm != null) {
      for (final entry in cm.entries) {
        final vk = entry.key;
        for (final fEntry in entry.value.entries) {
          for (final cdo in fEntry.value) {
            _add(copy, vk, fEntry.key, cdo);
          }
        }
      }
    }
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
