// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.QualifyFacet

import '../../base/cdom_object.dart';
import '../../enumeration/char_id.dart';
import '../../enumeration/list_key.dart';
import '../base/abstract_storage_facet.dart';
import '../cdom_object_consolidation_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// Tracks Qualifier objects — items the Player Character should qualify for.
class QualifyFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late CDOMObjectConsolidationFacet consolidationFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final qualList = cdo.getListFor(ListKey.getConstant<dynamic>('QUALIFY'));
    final ci = _getConstructingCacheInfo(dfce.getCharID());
    if (qualList != null) {
      for (final q in qualList) {
        ci.add(q, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final ci = getCache(dfce.getCharID()) as _CacheInfo?;
    ci?.removeAll(dfce.getCDOMObject());
  }

  _CacheInfo _getConstructingCacheInfo(CharID id) {
    var ci = getCache(id) as _CacheInfo?;
    if (ci == null) {
      ci = _CacheInfo();
      setCache(id, ci);
    }
    return ci;
  }

  /// Returns true if the Player Character has been granted qualification for the given object.
  bool grantsQualify(CharID id, CDOMObject qualTestObject) {
    final ci = getCache(id) as _CacheInfo?;
    return ci != null && ci.isQualified(qualTestObject);
  }

  int getCount(CharID id) {
    final ci = getCache(id) as _CacheInfo?;
    return ci?.qualsByFormat.length ?? 0;
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final ci = getCache(source) as _CacheInfo?;
    if (ci != null) {
      final copyci = _getConstructingCacheInfo(copy);
      for (final entry in ci.qualsByFormat.entries) {
        copyci.qualsByFormat.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
      for (final entry in ci.sourceMap.entries) {
        copyci.sourceMap.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}

class _CacheInfo {
  final Map<String, List<dynamic>> qualsByFormat = {};
  final Map<CDOMObject, List<dynamic>> sourceMap = {};

  void add(dynamic q, CDOMObject source) {
    final format = q.getQualifiedReference().getPersistentFormat() as String;
    qualsByFormat.putIfAbsent(format, () => []).add(q);
    sourceMap.putIfAbsent(source, () => []).add(q);
  }

  void removeAll(CDOMObject source) {
    final list = sourceMap.remove(source);
    if (list != null) {
      for (final q in list) {
        final format = q.getQualifiedReference().getPersistentFormat() as String;
        qualsByFormat[format]?.remove(q);
        if (qualsByFormat[format]?.isEmpty == true) qualsByFormat.remove(format);
      }
    }
  }

  bool isQualified(CDOMObject qualTestObject) {
    final format = qualTestObject.getClassIdentity().getPersistentFormat() as String;
    final list = qualsByFormat[format];
    if (list != null) {
      for (final q in list) {
        if (q.getQualifiedReference().contains(qualTestObject)) return true;
      }
    }
    return false;
  }
}
