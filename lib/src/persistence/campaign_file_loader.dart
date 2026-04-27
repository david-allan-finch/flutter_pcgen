//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.CampaignFileLoader

import 'dart:io';

import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_settings.dart';
import 'package:flutter_pcgen/src/system/language_bundle.dart';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';
import 'package:flutter_pcgen/src/persistence/recursive_file_finder.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_loader.dart';

/// Loads campaign (.pcc) files from the data directory tree and initialises
/// any inter-campaign dependencies (INFOTEXT, SUB-CAMPAIGN references).
class CampaignFileLoader extends PCGenTask {
  Directory? _alternateSourceFolder;

  @override
  String getMessage() =>
      LanguageBundle.getString('in_taskLoadCampaigns');

  @override
  Future<void> run() async {
    final finder = RecursiveFileFinder();
    final List<String> campaignFiles = [];

    if (_alternateSourceFolder != null) {
      finder.findFiles(_alternateSourceFolder!, campaignFiles);
    } else {
      final pccDir = Directory(ConfigurationSettings.getPccFilesDir());
      finder.findFiles(pccDir, campaignFiles);

      final vendorPath = PCGenSettings.getVendorDataDir();
      if (vendorPath.isNotEmpty) {
        final vendorDir = Directory(vendorPath);
        if (vendorDir.existsSync()) finder.findFiles(vendorDir, campaignFiles);
      }

      final homebrewPath = PCGenSettings.getHomebrewDataDir();
      if (homebrewPath.isNotEmpty) {
        final homebrewDir = Directory(homebrewPath);
        if (homebrewDir.existsSync()) finder.findFiles(homebrewDir, campaignFiles);
      }
    }

    setMaximum(campaignFiles.length);
    await _loadCampaigns(campaignFiles);
    _initCampaigns();
  }

  /// Passes each .pcc path to CampaignLoader; skips already-loaded campaigns.
  Future<void> _loadCampaigns(List<String> campaignFiles) async {
    int progress = 0;
    final loader = CampaignLoader();
    for (final path in campaignFiles) {
      final uri = Uri.parse(path);
      if (Globals.getCampaignByUri(uri) == null) {
        try {
          await loader.loadCampaignLstFile(uri);
        } on PersistenceLayerException catch (ex) {
          print('PersistenceLayer error loading $path: $ex');
        }
      }
      setProgress(progress++);
    }
  }

  /// Processes PCC sub-campaign references for all loaded campaigns.
  void _initCampaigns() {
    final initialCampaigns = List<Campaign>.from(Globals.getCampaignList());
    final loader = CampaignLoader();
    for (final campaign in initialCampaigns) {
      loader.initRecursivePccFiles(campaign);
    }
  }

  /// Override the source directory used when scanning for campaigns.
  void setAlternateSourceFolder(Directory folder) {
    _alternateSourceFolder = folder;
  }
}
