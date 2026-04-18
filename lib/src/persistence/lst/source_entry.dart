import '../../core/campaign.dart';
import '../../cdom/prereq/prerequisite.dart';

// Interface for an LST source file entry linked to a campaign.
abstract interface class SourceEntry {
  Campaign getCampaign();
  String getURI();
  List<String> getIncludeItems();
  List<String> getExcludeItems();
  List<Prerequisite> getPrerequisites();
}
