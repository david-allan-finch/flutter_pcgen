// Translation of pcgen.gui2.converter.loader.SelfCopyLoader

import '../conversion_decider.dart';
import '../loader.dart';

/// A [Loader] that copies lines verbatim and returns the campaign's own PCC
/// file as the single entry in [getFiles].  Used to ensure the campaign
/// descriptor file itself is written to the output directory.
class SelfCopyLoader implements Loader {
  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    sb.write(lineString);
    return null;
  }

  @override
  List<dynamic> getFiles(dynamic campaign) {
    // Returns a single CampaignSourceEntry pointing at the campaign's own URI.
    return [_SelfCampaignSourceEntry(campaign, campaign.getSourceUri())];
  }
}

/// Lightweight stand-in for Java's CampaignSourceEntry when pointing a
/// campaign at its own source file.
class _SelfCampaignSourceEntry {
  final dynamic campaign;
  final Uri uri;

  _SelfCampaignSourceEntry(this.campaign, this.uri);

  Uri getUri() => uri;
  dynamic getCampaign() => campaign;
}
