// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.DomainSpellCountFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_association_facet.dart';

/// Stores the number of Domain spells available to a given [PCClass] for a
/// Player Character.
class DomainSpellCountFacet
    extends AbstractAssociationFacet<CharID, PCClass, int> {}
