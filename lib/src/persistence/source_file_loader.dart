// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.persistence.SourceFileLoader

import '../core/campaign.dart';

/// Loads source data files for a selected set of campaigns into the game data context.
class SourceFileLoader {
  final List<Campaign> _campaigns;

  SourceFileLoader(this._campaigns);

  String getMessage() => 'Loading source files...';

  /// Loads all LST files referenced by the selected campaigns.
  Future<void> run() async {
    // TODO: resolve INCLUDE/EXCLUDE, load each referenced LST file through
    // the appropriate loader (ability, class, race, deity, spell, etc.)
  }

  List<Campaign> getCampaigns() => List.unmodifiable(_campaigns);
}
