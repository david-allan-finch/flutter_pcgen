// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.DirectAbilityFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_cnas_enforcing_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';

/// Tracks [CNAbilitySelection] objects directly granted to a Player Character
/// (as opposed to conditionally or via a parent object).
class DirectAbilityFacet extends AbstractCNASEnforcingFacet {
  /// Removes all [CNAbilitySelection] objects sourced from [source].
  void removeAllFromSource(CharID id, Object source) {
    final list = getList(id);
    if (list == null) return;

    final removed = <CNAbilitySelection>[];
    final added = <CNAbilitySelection>[];

    final listIt = list.iterator;
    final toRemoveLists = <List<SourcedCNAS>>[];

    for (final array in list) {
      final length = array.length;
      for (int j = length - 1; j >= 0; j--) {
        final sc = array[j];
        if (source == sc.source) {
          array.removeAt(j);
          bool needRemove = true;
          if (array.isNotEmpty) {
            final newPrimary = array[0].cnas;
            if (sc.cnas != newPrimary && j == 0) {
              added.add(newPrimary);
            } else {
              needRemove = false;
            }
          }
          if (needRemove) {
            removed.add(sc.cnas);
          }
        }
      }
      if (array.isEmpty) {
        toRemoveLists.add(array);
      }
    }
    list.removeWhere((a) => a.isEmpty);

    for (final cnas in removed) {
      fireDataFacetChangeEvent(id, cnas, DataFacetChangeEvent.dataRemoved);
    }
    for (final cnas in added) {
      fireDataFacetChangeEvent(id, cnas, DataFacetChangeEvent.dataAdded);
    }
  }
}
