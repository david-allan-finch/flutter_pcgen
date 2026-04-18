// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

// dynamic: Campaign (not yet translated)

/// ExpandedCampaignFacet tracks the Campaign objects loaded with a Player
/// Character, including both explicitly and implicitly (via PCC:) loaded
/// campaigns.
///
/// Explicitly loaded Campaign objects are stored in CampaignFacet.
class ExpandedCampaignFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {

  /// Expands the loaded campaign to include its subcampaigns.
  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
    // stub: addAll(dfce.getCharID(), dfce.getCDOMObject().getSubCampaigns(), dfce.getSource());
  }

  /// Removes the campaign and its subcampaigns.
  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject(), dfce.getSource());
    // stub: removeAll(dfce.getCharID(), dfce.getCDOMObject().getSubCampaigns(), dfce.getSource());
  }
}
