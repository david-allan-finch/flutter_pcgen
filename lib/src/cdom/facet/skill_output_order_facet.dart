// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.SkillOutputOrderFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'base/abstract_association_facet.dart';

/// Stores the order for Skills and how they should be output for a Player
/// Character. Skill is typed as [dynamic].
class SkillOutputOrderFacet extends AbstractAssociationFacet<CharID, dynamic, int> {}
