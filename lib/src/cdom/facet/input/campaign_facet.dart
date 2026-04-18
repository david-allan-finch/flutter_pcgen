// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/CampaignFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_list_facet.dart';

/// CampaignFacet is a Facet that tracks the Campaigns loaded and thus active on
/// a Player Character. This tracks the list of Campaigns selected by the user.
/// This list must be expanded if any of the Campaigns includes another Campaign
/// (PCC file).
class CampaignFacet extends AbstractListFacet<CharID, dynamic> {
  dynamic expandedCampaignFacet; // ExpandedCampaignFacet

  void setExpandedCampaignFacet(dynamic expandedCampaignFacet) {
    this.expandedCampaignFacet = expandedCampaignFacet;
  }

  void init() {
    addDataFacetChangeListener(expandedCampaignFacet);
  }
}
