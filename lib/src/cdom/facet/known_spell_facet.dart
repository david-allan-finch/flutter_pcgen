// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.KnownSpellFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'base/abstract_sub_scope_facet.dart';

/// Tracks the Known Spells (post-prerequisite-resolution) for a Player
/// Character, keyed by [CDOMList<Spell>] (spell list) and spell level.
class KnownSpellFacet
    extends AbstractSubScopeFacet<CharID, CDOMList<Spell>, int, Spell> {}
