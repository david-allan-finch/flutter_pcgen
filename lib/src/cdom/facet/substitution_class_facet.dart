// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.SubstitutionClassFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_association_facet.dart';

/// Stores the substitution class identifier for each [PCClassLevel] on a PC.
class SubstitutionClassFacet
    extends AbstractAssociationFacet<CharID, PCClassLevel, String> {}
