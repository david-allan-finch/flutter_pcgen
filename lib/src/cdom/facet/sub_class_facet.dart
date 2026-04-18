// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.SubClassFacet

import '../enumeration/char_id.dart';
import '../../core/pc_class.dart';
import 'base/abstract_association_facet.dart';

/// Stores the SubClass identifier for each [PCClass] on a Player Character.
class SubClassFacet extends AbstractAssociationFacet<CharID, PCClass, String> {}
