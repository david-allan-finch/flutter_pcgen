// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.FollowerOptionFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../base/abstract_storage_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// Tracks FollowerOption objects (COMPANIONLIST token) for a Player Character.
///
/// Cache: Map<String (list name, case-insensitive), Map<FollowerOption (identity), Set<CDOMObject (identity)>>>
class FollowerOptionFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final lists = cdo.getListFor(ListKey.getConstant<dynamic>('COMPANIONLIST'));
    if (lists != null) {
      for (final fo in lists) {
        _add(dfce.getCharID(), fo, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    _removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  void _add(CharID id, dynamic fo, CDOMObject cdo) {
    final name = (fo.listRef.getName() as String).toLowerCase();
    final foMap = _getConstructingCachedMap(id, name);
    foMap.putIfAbsent(fo, () => <CDOMObject>{}).add(cdo);
  }

  void _removeAll(CharID id, CDOMObject source) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return;
    componentMap.removeWhere((name, foMap) {
      foMap.removeWhere((fo, sources) {
        sources.remove(source);
        return sources.isEmpty;
      });
      return foMap.isEmpty;
    });
  }

  /// Returns all FollowerOption objects for a given companion list name.
  Set<dynamic> getFollowerOptions(CharID id, String companionListName) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return {};
    return componentMap[companionListName.toLowerCase()]?.keys.toSet() ?? {};
  }

  /// Returns all FollowerOption objects for the Player Character.
  Set<dynamic> getAllFollowerOptions(CharID id) {
    final componentMap = _getCachedMap(id);
    if (componentMap == null) return {};
    return {
      for (final foMap in componentMap.values) ...foMap.keys
    };
  }

  Map<String, Map<dynamic, Set<CDOMObject>>>? _getCachedMap(CharID id) =>
      getCache(id) as Map<String, Map<dynamic, Set<CDOMObject>>>?;

  Map<dynamic, Set<CDOMObject>> _getConstructingCachedMap(CharID id, String name) {
    var componentMap = _getCachedMap(id);
    if (componentMap == null) {
      componentMap = {};
      setCache(id, componentMap);
    }
    return componentMap.putIfAbsent(name, () => {});
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
