// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.ConditionalAbilityFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/helper/cn_ability_selection.dart';
import 'base/abstract_single_source_list_facet.dart';
import 'prerequisite_facet.dart';

/// Stores all conditionally-granted [CNAbilitySelection] objects for a Player
/// Character. [ConditionallyGrantedAbilityFacet] determines which are active
/// by checking prerequisites via [PrerequisiteFacet].
class ConditionalAbilityFacet
    extends AbstractSingleSourceListFacet<CNAbilitySelection, Object> {
  late PrerequisiteFacet prerequisiteFacet;

  /// Returns all [CNAbilitySelection] objects the PC currently qualifies for.
  List<CNAbilitySelection> getQualifiedSet(CharID id) {
    final result = <CNAbilitySelection>[];
    final cached = getCachedMap(id);
    if (cached != null) {
      for (final entry in cached.entries) {
        if (prerequisiteFacet.qualifies(id, entry.key, entry.value)) {
          result.add(entry.key);
        }
      }
    }
    return result;
  }

  /// Returns true if the PC currently qualifies for [cas].
  bool isQualified(CharID id, CNAbilitySelection cas) {
    final cached = getCachedMap(id);
    if (cached != null) {
      final source = cached[cas];
      if (source != null) {
        return prerequisiteFacet.qualifies(id, cas, source);
      }
    }
    return false;
  }
}
