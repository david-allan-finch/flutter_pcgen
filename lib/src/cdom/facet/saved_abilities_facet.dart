// Copyright (c) Thomas Parker, 2014.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.SavedAbilitiesFacet

import '../enumeration/char_id.dart';
import 'base/abstract_list_facet.dart';

/// Tracks saved CNAbilitySelection objects for a Player Character.
///
/// CNAbilitySelection is referenced as [dynamic] since it has not yet been
/// translated.
class SavedAbilitiesFacet extends AbstractListFacet<CharID, dynamic> {}
