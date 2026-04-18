// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.ConditionallyKnownSpellFacet

import '../helper/available_spell.dart';
import 'base/abstract_qualified_list_facet.dart';

/// Tracks conditionally-known spells (those with prerequisites) for a Player
/// Character. Used together with [KnownSpellFacet] for the full known spell set.
class ConditionallyKnownSpellFacet
    extends AbstractQualifiedListFacet<AvailableSpell> {}
