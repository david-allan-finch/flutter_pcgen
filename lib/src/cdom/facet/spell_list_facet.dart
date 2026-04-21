// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SpellListFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';

/// Maintains the list of spell lists for a Player Character.
class SpellListFacet
    extends AbstractSourcedListFacet<CharID, CDOMList<Spell>> {
  @override
  void add(CharID id, CDOMList<Spell> obj, Object? source) {
    // Guard against null spell lists (e.g., non-spell-casting classes).
    // ignore: unnecessary_null_comparison
    if (obj == null) return;
    super.add(id, obj, source);
  }
}
