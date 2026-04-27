// Copyright PCGen authors.
//
// Translation of pcgen.persistence.lst.LstSystemLoader (deprecated in Java)
// and the broader system-loader responsibilities described in SystemLoader.

import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/persistence/game_mode_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/campaign_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_loader.dart';

/// Coordinates the two-phase startup loading pipeline:
///  1. [loadSystemResources] — game modes + campaign discovery (run at launch)
///  2. [loadCampaigns] — parse selected .pcc files (run after user picks sources)
///
/// Also maintains the chosen-source-files registry per game mode, mirroring
/// the SystemLoader interface contract from the Java original.
class LstSystemLoader {
  /// Map from game-mode name → list of chosen source-file URI strings.
  final Map<String, List<String>> _chosenCampaignSourcefiles = {};

  // ---------------------------------------------------------------------------
  // Chosen source-file management (mirrors SystemLoader contract)
  // ---------------------------------------------------------------------------

  void setChosenCampaignSourcefiles(List<String> uris, String gameModeName) {
    _chosenCampaignSourcefiles[gameModeName] = List<String>.from(uris);
    // TODO: persist via PCGenSettings.setProperty(
    //   'pcgen.files.chosenCampaignSourcefiles.$gameModeName', uris.join(', '))
  }

  List<String> getChosenCampaignSourcefiles(String gameModeName) {
    return _chosenCampaignSourcefiles.putIfAbsent(gameModeName, () => []);
  }

  // ---------------------------------------------------------------------------
  // Phase 1: System resource loading
  // ---------------------------------------------------------------------------

  /// Loads all system-level LST resources required before campaigns can be
  /// selected, then discovers all available campaign (.pcc) files.
  ///
  /// Loading order:
  ///  1. Game modes — reads every gameModes/ subdirectory that contains
  ///     miscinfo.lst + statsandchecks.lst; each mode also loads bio settings,
  ///     level info, size adjustments, load info, point-buy methods, traits,
  ///     locations, and equipment slots (all via GameModeFileLoader).
  ///  2. Campaign discovery — scans data/, vendordata/, homebrewdata/ for
  ///     .pcc files and registers them in the global campaign registry.
  ///
  /// [onProgress] receives a 0.0–1.0 fraction and a status string after each
  /// major step so the splash screen can update.
  Future<void> loadSystemResources({
    void Function(double progress, String message)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Loading game modes…');
    await GameModeFileLoader().run();

    onProgress?.call(0.7, 'Discovering campaigns…');
    await CampaignFileLoader().run();

    onProgress?.call(1.0, 'System resources loaded.');
  }

  // ---------------------------------------------------------------------------
  // Phase 2: Selected campaign loading
  // ---------------------------------------------------------------------------

  /// Parses the .pcc files at [campaignUris] and resolves their dependencies.
  ///
  /// This registers each campaign in the global registry and wires up any
  /// SUB-CAMPAIGN references. The actual object-file loading (races, classes,
  /// spells, etc.) is handled separately by SourceFileLoader once the user
  /// confirms their source selection.
  ///
  /// Returns true if every URI was loaded without a fatal error.
  Future<bool> loadCampaigns(List<String> campaignUris) async {
    bool success = true;
    final loader = CampaignLoader();

    for (final rawUri in campaignUris) {
      final uri = Uri.parse(rawUri);
      if (Globals.getCampaignByUri(uri) != null) continue;
      try {
        await loader.loadCampaignLstFile(uri);
      } catch (e) {
        print('LstSystemLoader: error loading campaign $rawUri: $e');
        success = false;
      }
    }

    // Resolve SUB-CAMPAIGN / INFOTEXT dependencies for every newly loaded campaign.
    for (final rawUri in campaignUris) {
      final Campaign? campaign = Globals.getCampaignByUri(Uri.parse(rawUri));
      if (campaign != null) loader.initRecursivePccFiles(campaign);
    }

    return success;
  }
}
