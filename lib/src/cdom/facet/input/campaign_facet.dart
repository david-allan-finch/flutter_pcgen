//
// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.facet.input.CampaignFacet
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
