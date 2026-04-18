// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.CampaignInfoFactory

abstract interface class CampaignInfoFactory {
  String getHTMLInfo(dynamic campaign);
  String getHTMLInfoWithSelected(dynamic campaign, List<dynamic> selectedCampaigns);
  String getHTMLInfoForSelection(dynamic selection);
  String getRequirementsHTMLString(dynamic campaign, List<dynamic> selectedCampaigns);
}
