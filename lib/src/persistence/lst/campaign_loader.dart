// Translation of pcgen.persistence.lst.CampaignLoader

import '../../core/campaign.dart';
import '../../core/globals.dart';
import '../persistence_layer_exception.dart';

/// Loads a campaign (.pcc) file into the global campaign registry.
///
/// A .pcc file contains metadata and file lists (ABILITY, CLASS, RACE, etc.)
/// for a source book or homebrew supplement.
class CampaignLoader {
  /// Loads a single campaign PCC file from [uri] into Globals.
  Future<void> loadCampaignLstFile(Uri uri) async {
    // TODO: read the PCC file, parse each token line, populate campaign object
    final campaign = Campaign();
    campaign.setSourceUri(uri);

    // Derive a key from the URI (use last path segment without extension)
    final path = uri.path;
    final fileName = path.split('/').last;
    final keyName = fileName.endsWith('.pcc')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    campaign.setName(keyName);

    Globals.addCampaign(campaign);
  }

  /// Processes INFOTEXT and SUB-CAMPAIGN tags to load any campaigns
  /// that [campaign] depends on.
  void initRecursivePccFiles(Campaign campaign) {
    // TODO: load dependent campaigns listed under the campaign's
    // INFOTEXT/SUBFILELIST/ALLOWDUPES tokens
  }
}
