// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.XPTableFacet

import '../enumeration/char_id.dart';
import '../../core/level_info.dart';
import '../../core/xp_table.dart';
import 'base/abstract_item_facet.dart';

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
