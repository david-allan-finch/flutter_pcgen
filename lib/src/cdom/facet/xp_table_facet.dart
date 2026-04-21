// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.XPTableFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/level_info.dart';
import 'package:flutter_pcgen/src/core/xp_table.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';

/// Tracks the [XPTable] assigned to a Player Character, providing level info
/// lookups.
class XPTableFacet extends AbstractItemFacet<CharID, XPTable> {
  /// Returns the [LevelInfo] for [level], or null if not available.
  LevelInfo? getLevelInfo(CharID id, int level) {
    if (level < 1) return null;
    final table = get(id);
    if (table == null) return null;
    return table.getLevelInfo(level.toString()) ?? table.getLevelInfo('LEVEL');
  }
}
