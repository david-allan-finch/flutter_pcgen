// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.analysis.RacialSubTypesFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/race_sub_type.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/race_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/template_facet.dart';

/// Tracks the Racial Sub Types of a Player Character.
class RacialSubTypesFacet {
  late TemplateFacet templateFacet;
  late RaceFacet raceFacet;

  /// Returns the collection of Racial Sub Types for the Player Character.
  List<RaceSubType> getRacialSubTypes(CharID id) {
    final racialSubTypes = <RaceSubType>[];
    final race = raceFacet.get(id);
    if (race != null) {
      racialSubTypes.addAll(race.getSafeListFor(
          ListKey.getConstant<RaceSubType>('RACESUBTYPE')));
    }
    final templates = templateFacet.getSet(id);
    if (templates.isNotEmpty) {
      final added = <RaceSubType>[];
      final removed = <RaceSubType>[];
      for (final tmpl in templates) {
        added.addAll(tmpl.getSafeListFor(
            ListKey.getConstant<RaceSubType>('RACESUBTYPE')));
        removed.addAll(tmpl.getSafeListFor(
            ListKey.getConstant<RaceSubType>('REMOVED_RACESUBTYPE')));
      }
      racialSubTypes.addAll(added);
      racialSubTypes.removeWhere(removed.contains);
    }
    return List.unmodifiable(racialSubTypes);
  }

  bool contains(CharID id, RaceSubType subType) =>
      getRacialSubTypes(id).contains(subType);

  int getCount(CharID id) => getRacialSubTypes(id).length;
}
