// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.persistence.CampaignFileLoader

import 'dart:io';

import '../core/campaign.dart';
import 'recursive_file_finder.dart';

/// Loads campaign (.pcc) files from the data directory tree.
class CampaignFileLoader {
  Directory? _alternateSourceFolder;

  String getMessage() => 'Loading campaigns...';

  void setAlternateSourceFolder(Directory folder) {
    _alternateSourceFolder = folder;
  }

  /// Scans the source directories for .pcc files and loads each campaign.
  Future<void> run() async {
    final finder = RecursiveFileFinder();
    final campaignFiles = <Uri>[];

    if (_alternateSourceFolder != null) {
      await finder.findFiles(_alternateSourceFolder!, campaignFiles);
    }
    // In the full implementation this would also scan vendorDataDir, homebrewDataDir etc.

    for (final uri in campaignFiles) {
      // TODO: Load campaign via CampaignLoader
    }
  }
}
