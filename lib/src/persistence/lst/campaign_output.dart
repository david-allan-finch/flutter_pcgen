// Translation of pcgen.persistence.lst.CampaignOutput

import 'dart:io';
import '../../core/campaign.dart';
import '../../rules/context/load_context.dart';

/// Utility class (no instances) that writes a Campaign back out to a .pcc file.
///
/// Used when saving a modified campaign to disk (e.g. after the editor modifies it).
final class CampaignOutput {
  CampaignOutput._();

  /// Writes [campaign] to its destination .pcc file.
  ///
  /// The destination path is derived from the campaign's DESTINATION StringKey
  /// relative to the PCC files directory.
  static Future<void> output(LoadContext context, Campaign campaign) async {
    // TODO: resolve destination path from ConfigurationSettings.getPccFilesDir()
    //       and campaign.getSafe(StringKey.destination)
    // TODO: write COMMENT lines from campaign's comment list
    // TODO: call context.unparse(campaign) to get LST lines and write them
  }
}
