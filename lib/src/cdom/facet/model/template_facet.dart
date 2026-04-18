// Copyright (c) Thomas Parker, 2012.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

// stub: OutputDB.register("templates", this)
// dynamic: PCTemplate (not yet translated)

/// TemplateFacet tracks all PCTemplates that have been granted to a Player
/// Character. Uses a LinkedHashMap because PCTemplates are order-sensitive.
class TemplateFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
  }

  /// Returns an insertion-ordered map for storage.
  /// PCTemplates are order sensitive when applied to a PC.
  @override
  Map<dynamic, Set<Object?>> getComponentMap() {
    return <dynamic, Set<Object?>>{};
    // Note: Dart's regular Map preserves insertion order, equivalent to LinkedHashMap
  }

  void init() {
    // stub: OutputDB.register("templates", this)
  }
}
