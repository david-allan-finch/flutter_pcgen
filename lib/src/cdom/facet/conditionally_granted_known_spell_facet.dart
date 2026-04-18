// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.ConditionallyGrantedKnownSpellFacet

import '../enumeration/char_id.dart';
import 'conditionally_known_spell_facet.dart';
import 'known_spell_facet.dart';

/// Promotes qualified known spells from the conditional facet into the active
/// [KnownSpellFacet].
class ConditionallyGrantedKnownSpellFacet {
  late ConditionallyKnownSpellFacet conditionallyKnownSpellFacet;
  late KnownSpellFacet knownSpellFacet;

  void update(CharID id) {
    for (final as_ in conditionallyKnownSpellFacet.getQualifiedSet(id)) {
      final sources = conditionallyKnownSpellFacet.getSources(id, as_);
      for (final source in sources) {
        knownSpellFacet.add(
            id, as_.getSpelllist(), as_.getLevel(), as_.getSpell(), source);
      }
    }
  }
}
