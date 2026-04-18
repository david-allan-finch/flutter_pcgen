// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by the
// Free Software Foundation; either version 2.1 of the License, or (at your
// option) any later version.

// Translation of pcgen.cdom.facet.PrimaryWeaponFacet

import '../enumeration/char_id.dart';
import '../../core/equipment.dart';
import 'base/abstract_list_facet.dart';

/// Contains the list of weapons that are Primary Weapons for a Player Character.
class PrimaryWeaponFacet extends AbstractListFacet<CharID, Equipment> {
  @override
  Set<Equipment> getCopyForNewOwner(Set<Equipment> componentSet) {
    return {for (final e in componentSet) e.clone()};
  }
}
