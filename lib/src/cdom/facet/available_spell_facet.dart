// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.AvailableSpellFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/list/class_spell_list.dart';
import 'package:flutter_pcgen/src/cdom/list/domain_spell_list.dart';
import 'package:flutter_pcgen/src/base/util/hash_map_to_list.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sub_scope_facet.dart';

/// Tracks the spells available to a Player Character keyed by
/// CDOMList<Spell> (spell list) and level.
class AvailableSpellFacet
    extends AbstractSubScopeFacet<CDOMList<Spell>, int, Spell> {
  /// Returns a map of spell list → available levels for [sp] on the PC.
  HashMapToList<CDOMList<Spell>, int> getSpellLevelInfo(CharID id, Spell sp) {
    final levelInfo = HashMapToList<CDOMList<Spell>, int>();

    final listMap = getCache(id)
        as Map<CDOMList<Spell>, Map<int, Map<Spell, Set<Object>>>>?;
    if (listMap == null) return levelInfo;

    for (final listEntry in listMap.entries) {
      final list = listEntry.key;
      if (list is! ClassSpellList && list is! DomainSpellList) continue;

      for (final levelEntry in listEntry.value.entries) {
        final level = levelEntry.key;
        final spellMap = levelEntry.value;
        if (spellMap.containsKey(sp)) {
          levelInfo.addToListFor(list, level);
        } else {
          for (final spell in spellMap.keys) {
            if (spell.getKeyName() == sp.getKeyName()) {
              levelInfo.addToListFor(list, level);
            }
          }
        }
      }
    }
    return levelInfo;
  }
}
