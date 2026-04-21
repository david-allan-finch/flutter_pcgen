// Copyright (c) Tom Parker, 2016.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_scope_facet_consolidator.dart';

// dynamic: Category<Dynamic>, Dynamic (not yet translated)

/// DynamicConsolidationFacet consolidates scope-facet change events for
/// Dynamic objects (keyed by Category<Dynamic>) into a flat list.
class DynamicConsolidationFacet
    extends AbstractScopeFacetConsolidator<dynamic, dynamic> {
  // No additional members - all behaviour from AbstractScopeFacetConsolidator
}
