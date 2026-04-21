// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.SubClassFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'base/abstract_association_facet.dart';

/// Stores the SubClass identifier for each [PCClass] on a Player Character.
class SubClassFacet extends AbstractAssociationFacet<CharID, PCClass, String> {}
