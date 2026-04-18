// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.RaceSelectionFacet

import '../enumeration/char_id.dart';
import 'base/abstract_association_facet.dart';

/// Tracks the Race of a Player Character with the CHOOSE selection that was
/// made. Race is typed as [dynamic] since it has not yet been translated.
class RaceSelectionFacet extends AbstractAssociationFacet<CharID, dynamic, dynamic> {}
