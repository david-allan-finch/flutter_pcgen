// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.SpellSupportFacet

import '../enumeration/char_id.dart';
import '../../core/pc_class.dart';
import '../../core/spell_support_for_pc_class.dart';
import 'base/abstract_association_facet.dart';

/// Stores the [SpellSupportForPCClass] associated with each [PCClass] on a
/// Player Character, providing access to spell slot and casting data.
class SpellSupportFacet
    extends AbstractAssociationFacet<CharID, PCClass, SpellSupportForPCClass> {}
