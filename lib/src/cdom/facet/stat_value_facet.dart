// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.StatValueFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/scope_facet_change_event.dart';

/// Stores the base values of [PCStat] objects (e.g. Strength = 18) for each
/// Player Character.
///
/// Supports two storage modes:
///   - Legacy: stores values in an identity-keyed map per CharID.
///   - Channel (new formula system): delegates to [VariableStoreFacet] via a
///     named channel. The channel path is not yet implemented; it falls back to
///     the legacy map. TODO: implement channel-based stat storage.
class StatValueFacet extends AbstractScopeFacet<CharID, PCStat, num> {
  // TODO: wire LoadContextFacet + ScopeFacet + VariableStoreFacet for channel mode.

  /// Returns the stat value for [stat] on the PC identified by [id], or null.
  num? get(CharID id, PCStat stat) {
    final map = getCachedMap(id);
    return map?[stat];
  }

  /// Sets the base value for [stat] on the PC identified by [id].
  void set(CharID id, PCStat stat, num value) {
    final map = getConstructingCachedMap(id);
    final old = map[stat];
    map[stat] = value;
    if (old != null) {
      fireScopeFacetChangeEvent(
          id, stat, old, ScopeFacetChangeEvent.dataRemoved);
    }
    fireScopeFacetChangeEvent(id, stat, value, ScopeFacetChangeEvent.dataAdded);
  }

  @override
  void copyContents(CharID source, CharID destination) {
    final sourceMap = getCachedMap(source);
    if (sourceMap != null) {
      getConstructingCachedMap(destination).addAll(sourceMap);
    }
  }

  Map<PCStat, num>? getCachedMap(CharID id) =>
      getCache(id) as Map<PCStat, num>?;

  Map<PCStat, num> getConstructingCachedMap(CharID id) {
    var map = getCachedMap(id);
    if (map == null) {
      map = <PCStat, num>{};
      setCache(id, map);
    }
    return map;
  }
}
