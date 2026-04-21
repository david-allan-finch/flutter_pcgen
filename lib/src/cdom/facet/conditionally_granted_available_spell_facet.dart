// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.cdom.facet.ConditionallyGrantedAvailableSpellFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/available_spell_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/conditionally_available_spell_facet.dart';

/// Promotes qualified available spells from the conditional facet into the
/// active [AvailableSpellFacet].
class ConditionallyGrantedAvailableSpellFacet {
  late ConditionallyAvailableSpellFacet conditionallyAvailableSpellFacet;
  late AvailableSpellFacet availableSpellFacet;

  void update(CharID id) {
    for (final as_ in conditionallyAvailableSpellFacet.getQualifiedSet(id)) {
      final sources = conditionallyAvailableSpellFacet.getSources(id, as_);
      for (final source in sources) {
        availableSpellFacet.add(
            id, as_.getSpelllist(), as_.getLevel(), as_.getSpell(), source);
      }
    }
  }
}
