import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents a campaign/source book that can be loaded.
class Campaign extends PObject {
  bool _loaded = false;
  bool _published = false;

  bool isLoaded() => _loaded;
  void setLoaded(bool loaded) { _loaded = loaded; }

  bool isPublished() => _published;
  void setPublished(bool published) { _published = published; }

  String getDestination() => getSafeString(StringKey.destination);

  int getCampaignRank() => getSafeInt(IntegerKey.campaignRank);

  List<String> getSources() =>
      getSafeListFor<String>(ListKey.getConstant<String>('CAMPAIGN_SOURCE'));

  @override
  String toString() => getDisplayName();
}
