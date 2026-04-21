// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.AgeSetKitFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/age_set.dart';
import 'package:flutter_pcgen/src/core/bio_set.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'base/abstract_storage_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'analysis/age_set_facet.dart';
import 'model/bio_set_facet.dart';
import 'player_character_tracking_facet.dart';

/// Manages AgeSet Kit selections for a Player Character.
class AgeSetKitFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, int> {
  late PlayerCharacterTrackingFacet trackingFacet;
  late AgeSetFacet ageSetFacet;
  late BioSetFacet bioSetFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, int> dfce) {
    final id = dfce.getCharID();
    final ageSet = ageSetFacet.get(id);
    final pc = trackingFacet.getPC(id);
    if (ageSet == null || pc.isImporting()) return;
    final ageSetIndex = ageSetFacet.getAgeSetIndex(id);
    if (!pc.hasMadeKitSelectionForAgeSet(ageSetIndex)) {
      final cache = _getConstructingCache(id);
      final kits = cache.get(ageSet);
      if (kits != null) {
        final bioSet = bioSetFacet.get(id);
        for (final kit in ageSet.getKits()) {
          final choice = kit.driveChoice(pc);
          cache.put(ageSet, choice);
          kit.act(choice, bioSet, pc);
        }
      }
      pc.setHasMadeKitSelectionForAgeSet(ageSetIndex, true);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, int> dfce) {
    // Kits are fire-and-forget; no removal currently
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final ci = _getCache(source);
    if (ci != null) {
      _getConstructingCache(copy).copyFrom(ci);
    }
  }

  _CacheInfo? _getCache(CharID id) => getCache(id) as _CacheInfo?;

  _CacheInfo _getConstructingCache(CharID id) {
    var info = _getCache(id);
    if (info == null) {
      info = _CacheInfo();
      setCache(id, info);
    }
    return info;
  }
}

class _CacheInfo {
  final Map<AgeSet, List<Kit>> _kitMap = {};

  List<Kit>? get(AgeSet ageSet) => _kitMap[ageSet];

  void put(AgeSet ageSet, Iterable<Kit> choice) {
    (_kitMap[ageSet] ??= []).addAll(choice);
  }

  void copyFrom(_CacheInfo other) {
    for (final entry in other._kitMap.entries) {
      (_kitMap[entry.key] ??= []).addAll(entry.value);
    }
  }
}
