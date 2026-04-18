// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.SkillPoolFacet

import '../enumeration/char_id.dart';
import 'base/abstract_association_facet.dart';

/// Stores the number of Skill Points associated to a specific PCClass for a
/// Player Character. PCClass is typed as [dynamic].
class SkillPoolFacet extends AbstractAssociationFacet<CharID, dynamic, int> {}
