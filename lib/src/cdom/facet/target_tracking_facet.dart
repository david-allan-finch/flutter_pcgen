// Copyright (c) Thomas Parker, 2014.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.TargetTrackingFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'base/abstract_association_facet.dart';

/// Tracks the association between AbilitySelection (dynamic) and
/// CNAbilitySelection (dynamic) for a Player Character.
class TargetTrackingFacet extends AbstractAssociationFacet<CharID, dynamic, dynamic> {}
