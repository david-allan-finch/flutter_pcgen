// Copyright PCGen authors.
//
// Translation of pcgen.persistence.lst.LstSystemLoader (deprecated in Java)
// and the broader system-loader responsibilities described in SystemLoader.

/// Manages the set of chosen campaign source-files per game mode and
/// coordinates loading of system-level LST resources.
///
/// The Java LstSystemLoader was deprecated but still provides the
/// chosenCampaignSourcefiles registry and setChosenCampaignSourcefiles /
/// getChosenCampaignSourcefiles contract from SystemLoader. Those are
/// preserved here; the heavy system-file loading (gamemodes, biosettings,
/// etc.) is handled by the Flutter startup pipeline that calls into
/// individual loader classes directly.
///
/// Translation of pcgen.persistence.lst.LstSystemLoader.
class LstSystemLoader {
  /// Map from game-mode name → list of chosen source-file URI strings.
  final Map<String, List<String>> _chosenCampaignSourcefiles = {};

  // ---------------------------------------------------------------------------
  // Chosen source-file management (mirrors SystemLoader contract)
  // ---------------------------------------------------------------------------

  /// Replaces the chosen source files for [gameModeName] with [uris].
  ///
  /// Persists the setting for future sessions.
  void setChosenCampaignSourcefiles(
      List<String> uris, String gameModeName) {
    _chosenCampaignSourcefiles[gameModeName] = List<String>.from(uris);
    // TODO: persist to preferences / property store:
    //   PCGenSettings.setProperty(
    //     'pcgen.files.chosenCampaignSourcefiles.$gameModeName',
    //     uris.join(', '));
  }

  /// Returns the current list of chosen source file URIs for [gameModeName].
  ///
  /// Returns an empty list if none have been set.
  List<String> getChosenCampaignSourcefiles(String gameModeName) {
    return _chosenCampaignSourcefiles.putIfAbsent(gameModeName, () => []);
  }

  // ---------------------------------------------------------------------------
  // System resource loading
  // ---------------------------------------------------------------------------

  /// Loads all system-level LST resources required before campaigns can be
  /// selected.
  ///
  /// The loading order follows the Java SystemLoader pipeline:
  ///  1. Game mode list
  ///  2. Bio settings (age categories, body parts, etc.)
  ///  3. Traits and locations
  ///  4. Stats and checks
  ///  5. Miscellaneous system files (size adjustments, load info, etc.)
  ///
  /// [onProgress] is called with a 0.0–1.0 progress fraction after each
  /// major step, allowing the UI to display a loading indicator.
  Future<void> loadSystemResources({
    void Function(double progress, String message)? onProgress,
  }) async {
    // TODO: implement full system resource loading pipeline.
    //       Each step corresponds to one or more LstLineFileLoader subclasses.

    onProgress?.call(0.0, 'Starting system resource load…');

    // Step 1: Game modes.
    // TODO: GameModeLoader().loadGameModes(systemDir)
    onProgress?.call(0.2, 'Loading game modes…');

    // Step 2: Bio settings.
    // TODO: BioSetLoader().loadLstFiles(context, bioFiles)
    onProgress?.call(0.4, 'Loading bio settings…');

    // Step 3: Traits and locations.
    // TODO: TraitLoader, LocationLoader
    onProgress?.call(0.6, 'Loading traits and locations…');

    // Step 4: Stats and checks.
    // TODO: StatsAndChecksLoader
    onProgress?.call(0.8, 'Loading stats and checks…');

    // Step 5: Size adjustments, load info, point-buy methods, equipment slots.
    // TODO: SizeAdjustmentLoader, LoadInfoLoader, PointBuyLoader,
    //       EquipSlotLoader, WieldCategoryLoader, TabLoader
    onProgress?.call(1.0, 'System resources loaded.');
  }

  // ---------------------------------------------------------------------------
  // Campaign file loading
  // ---------------------------------------------------------------------------

  /// Loads the campaign (.PCC) files at [campaignUris] and processes the
  /// LST files they reference.
  ///
  /// Returns true if all campaigns loaded without fatal errors.
  Future<bool> loadCampaigns(List<String> campaignUris) async {
    // TODO: implement CampaignLoader pipeline and delegate to individual
    //       object-file loaders (RaceLoader, ClassLoader, FeatLoader, etc.).
    return false;
  }
}
