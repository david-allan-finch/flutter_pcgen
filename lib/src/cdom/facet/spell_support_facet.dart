// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.SpellSupportFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/spell_support_for_pc_class.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_association_facet.dart';

/// Stores the [SpellSupportForPCClass] associated with each [PCClass] on a
/// Player Character, providing access to spell slot and casting data.
class SpellSupportFacet
    extends AbstractAssociationFacet<CharID, PCClass, SpellSupportForPCClass> {}
