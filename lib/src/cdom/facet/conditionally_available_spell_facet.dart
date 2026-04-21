// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.ConditionallyAvailableSpellFacet

import 'package:flutter_pcgen/src/cdom/helper/available_spell.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_qualified_list_facet.dart';

/// Tracks conditionally-available spells (those with prerequisites) for a
/// Player Character.
class ConditionallyAvailableSpellFacet
    extends AbstractQualifiedListFacet<AvailableSpell> {}
