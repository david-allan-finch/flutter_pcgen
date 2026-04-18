// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_qualified_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

// stub: CorePerspectiveDB.register(CorePerspective.SHIELDPROF, FacetBehavior.MODEL, this)
// dynamic: ProfProvider<ShieldProf>, Equipment, ShieldProf (not yet translated)

/// ShieldProfProviderFacet tracks the ShieldProf ProfProviders granted to a
/// Player Character. Consolidates direct and indirect (via %LIST) shield profs.
class ShieldProfProviderFacet
    extends AbstractQualifiedListFacet<dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  /// Returns true if the Player Character is proficient with the given shield.
  bool isProficientWithShield(CharID id, dynamic eq) {
    for (final pp in getQualifiedSet(id)) {
      // stub: if (pp.providesProficiencyFor(eq)) return true;
    }
    return false;
  }

  String getIdentity() => 'Shield Proficiencies';

  void init() {
    // stub: CorePerspectiveDB.register(CorePerspective.SHIELDPROF, FacetBehavior.MODEL, this)
  }
}
