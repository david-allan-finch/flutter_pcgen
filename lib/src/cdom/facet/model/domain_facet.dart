// Copyright (c) Thomas Parker, 2009-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_single_source_list_facet.dart';

// stub: CorePerspectiveDB.register(CorePerspective.DOMAIN, FacetBehavior.MODEL, this)
// stub: OutputDB.register("domains", this)
// dynamic: Domain, ClassSource (not yet translated)

/// DomainFacet tracks the Domains possessed by a Player Character.
class DomainFacet extends AbstractSingleSourceListFacet<dynamic, dynamic> {

  String getIdentity() => 'Character Domains';

  void init() {
    // stub: CorePerspectiveDB.register(CorePerspective.DOMAIN, FacetBehavior.MODEL, this)
    // stub: OutputDB.register("domains", this)
  }
}
